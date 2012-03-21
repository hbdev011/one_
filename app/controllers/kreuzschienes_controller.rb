require 'csv'

class KreuzschienesController < ApplicationController
	layout "application", :except=>['update', 'update_device']

	# GET /kreuzschienes
	# GET /kreuzschienes.xml
	def index
		@kreuzschienes = Kreuzschiene.find(:all)
		respond_to do |format|
			format.html # index.html.erb
		end
	end

	# GET /kreuzschienes/1
	# GET /kreuzschienes/1.xml
	def edit

		session[:QUELLEN_CHANGE_ALL] = 0
		session[:SENKEN_CHANGE_ALL] = 0

		@system = System.find(cookies[:system_id])
		@kreuzschiene = Kreuzschiene.find(params[:id])
	        @families = Family.find(:all, :order => 'nummer ASC')
		if @kreuzschiene.system_id == @system.id
			@ref_matrix = Kreuzschiene.getAllNamedMatrix(@system).map{|m| [m.name, m.id]}

			if params[:page].nil?
				@page = "quellen"
			else
				@page = params[:page]
			end
			if @kreuzschiene.kr_type == "MIXER"

				if @page == "quellen"
					if !@kreuzschiene.ref_matrix_id.nil? && !@kreuzschiene.ref_matrix_id.blank?
						@ref_kr = Kreuzschiene.find(@kreuzschiene.ref_matrix_id)
						@setups = Source.find_all_by_kreuzschiene_id(@ref_kr.id, :order => "intnummer", :limit => @ref_kr.input)
						cnt = 0
						@kreuzschiene.getSources.each do |source|
							val = @setups[cnt]

							if val
								source.update_attributes(:name4stellig => val.name4stellig, :name5stellig => val.name5stellig, :char6 => val.char6, :char10 => val.char10, :comment => val.comment, :cloneinput => val.cloneinput, :matrix => val.matrix, :quelle => val.quelle, :tallybit => val.tallybit)
							end
							cnt+=1
						end
					end
				elsif @page == "senken"
					@setups = MixerTemplateSetup.find_all_by_mixer_template_id_and_system_id(@kreuzschiene.mixer_template_id, @system, :order => "intnummer")

					cnt = 0
					@kreuzschiene.getTargets.each do |@target|
						val = @setups[cnt]
						if val
						  @target.update_attributes(:name4stellig => val.name4stellig, :name5stellig => val.name5stellig, :char6 => val.char6, :char10 => val.char10, :comment => val.comment, :mx_tallybit => val.tallybit)
						end
						cnt+=1
					end
				end
			else
				if @kreuzschiene.kr_type == "MATRIX" && !@kreuzschiene.matrix_type.nil? && @kreuzschiene.matrix_type.title == "Lawo MONPL"
					@signals = SignalQuellen.getQuellenSignals.map{|u| [u.title, u.intnummer]} if @page == "quellen"
					@signals = SignalSenken.getSenkenSignals.map{|u| [u.title, u.intnummer]}  if @page == "senken"
					@subclass = getHLSDCollection
					@component = getHLSDCollection
					@subcomponent = getHLSDCollection
				end
			end

			@ch6 = []
			@ch6.push("")
			@kreuzschiene.getChar6.each {|e| @ch6.push(e.char6) }

			@tally = getTallyCollection

			@matrix = {}
			@matrix[""] = nil
			Kreuzschiene.getAllMatrix(@system.id).each {|e| @matrix[e.name] = e.name }
			# render :text => Global::MAXTALLYBIT.inspect and return false

			if @kreuzschiene.sources.empty? then
				@kreuzschiene.create_io
			end

			if @kreuzschiene.targets.empty? then
				@kreuzschiene.create_io
			end
			respond_to do |format|
				format.html # show.html.erb
			end
		else
			respond_to do |format|
				format.html { redirect_to :controller=>'systems', :action => "show", :id => @system.id }
			end
		end
	end


	# PUT /kreuzschienes/1
	# PUT /kreuzschienes/1.xml
	def update
		@system_id = cookies[:system_id]
		@kreuzschiene = Kreuzschiene.find(params[:kreuzschiene][:id])
		@result = nil
		@message = nil

		unit = params[:kreuzschiene][:unit]
		unit2 = params[:kreuzschiene][:unit2]
		port = params[:kreuzschiene][:port]
		port2 = params[:kreuzschiene][:port2]
		update_template = 0
		update_io = 0
		update_io_not = 0
		update_port = 0

		if !params[:kreuzschiene][:kr_type].nil? && @kreuzschiene.kr_type != params[:kreuzschiene][:kr_type]
			update_template = 1
		end

		if !params[:kreuzschiene][:mixer_template_id].nil? && @kreuzschiene.mixer_template_id != params[:kreuzschiene][:mixer_template_id].to_i
			old_output = (@kreuzschiene.output || 0)
			update_io = 1
		end

		if @kreuzschiene.kr_type == "MIXER"
			if (!params[:kreuzschiene][:input].nil? && params[:kreuzschiene][:input].to_i != @kreuzschiene.input)||(!params[:kreuzschiene][:output].nil? && params[:kreuzschiene][:output].to_i != @kreuzschiene.output)

				update_io_not = 1

				params[:kreuzschiene][:input] = @kreuzschiene.input.to_s
				params[:kreuzschiene][:output] = @kreuzschiene.output.to_s
			end
		end

		# hier muss man noch mal ran
#render :text => port.inspect and return false
		if (!port.nil? && !port.blank? && port.to_i != @kreuzschiene.port )
			html_id = "port1_#{@kreuzschiene.id}"
			opt = 1
			update_port = 1
		elsif (!port2.nil? && !port2.blank? && port2.to_i != @kreuzschiene.port2 )
			html_id = "port2_#{@kreuzschiene.id}"
			opt = 2
			update_port = 1
		end


		params[:kreuzschiene][:ip] = getIpFormat(params[:kreuzschiene][:ip])
		params[:kreuzschiene][:ip2] = getIpFormat(params[:kreuzschiene][:ip2])
		render :update do |page|

			if @kreuzschiene.update_attributes(params[:kreuzschiene])
				@message = (@message || '<font color="green">Kreuzschiene wurde gespeichert</font>')
			else
				@message = 'FEHLER'
			end

			if update_port == 1
				page.replace_html "#{html_id}", :partial => "shared/port_listbox", :locals => {:show => "link", :opt => opt}
			end

			if update_template == 1
				if @kreuzschiene.kr_type == "MIXER" || @kreuzschiene.kr_type.blank?
					@kreuzschiene.update_attributes(:mixer_template_id => 0)
				end

				@tpls = MixerTemplate.find(:all, :order => "intnummer").map {|u| [u.name, u.intnummer]}

				@m_types = MatrixType.getMatrixTypes.map {|u| [u.title, u.intnummer]}

				page.replace_html "tpl_#{@kreuzschiene.id}", :partial => "systems/templates"
				page.replace_html "kv_usernotice", "<font color='green'>Kreuzschiene wurde gespeichert</font>"
				page.replace_html "kv_usernotice", @message

			elsif update_io == 1
				@tpl = MixerTemplate.find_by_intnummer(@kreuzschiene.mixer_template_id)
				if !@tpl.nil?
					@kreuzschiene.update_attributes(:input => @tpl.input, :output => @tpl.output)
				end
				@setups = MixerTemplateSetup.find_all_by_mixer_template_id(@kreuzschiene.mixer_template_id, :order => "intnummer")
				new_output = (@kreuzschiene.output || 0)
				if new_output >= old_output
					cnt = 0
					@kreuzschiene.getTargets.each do |@target|
						val = @setups[cnt]
						@target.update_attributes(:name4stellig => val.name4stellig, :name5stellig => val.name5stellig, :char6 => val.char6, :char10 => val.char10, :comment => val.comment, :mx_tallybit => val.tallybit, :matrix => nil, :quelle => nil)
						cnt+=1
					end
				else
					@targets = @kreuzschiene.getTargets
					cnt = 0

					if new_output != 0
						@targets.each do |@target|
							val = @setups[cnt]
							@target.update_attributes(:name4stellig => val.name4stellig, :name5stellig => val.name5stellig, :char6 => val.char6, :char10 => val.char10, :comment => val.comment, :mx_tallybit => val.tallybit, :matrix => nil, :quelle => nil)
							cnt+=1
						end
					end

					@targets = Target.find_all_by_kreuzschiene_id(@kreuzschiene.id, :conditions => ["intnummer > ?",new_output], :limit=>old_output - new_output, :order=>"intnummer")
					cnt=0

					((old_output - new_output)-1).times{
						@targets[cnt].update_attributes(:name4stellig => nil, :name5stellig => nil, :char6 => nil, :char10 => nil, :comment => nil, :mx_tallybit => nil, :matrix => nil, :quelle => nil)
						cnt+=1
					}
				end
				if !@tpl.nil?
					page["#{@kreuzschiene.id}"]["kreuzschiene_input"]['value'] = @tpl.input
					page["#{@kreuzschiene.id}"]["kreuzschiene_output"]['value'] = @tpl.output
				end
				page.replace_html "kv_usernotice", @message

			elsif update_io_not == 1
				@message = '<font color="red">Dieser Wert kann nicht eingestellt werden</font>'

				page["#{@kreuzschiene.id}"]["kreuzschiene_input"]['value'] = @kreuzschiene.input
				page["#{@kreuzschiene.id}"]["kreuzschiene_output"]['value'] = @kreuzschiene.output
				page.replace_html "kv_usernotice", @message

			else
				page.replace_html "kv_usernotice", @message
			end
		end
	end

  def update_device
	@system_id = cookies[:system_id]
	@device = Device.find(params[:device][:id])
	update_port = 0

	unit = params[:device][:unit]
	port = params[:device][:port]

	# hier muss man noch mal ran

	if !port.nil? && !unit.nil? && port.to_i != @device.port
		update_port = 1
	end


	params[:device][:ip] = getIpFormat(params[:device][:ip])

	#render :text => params[:kreuzschiene][:ip].inspect and return false
	render :update do |page|
		if @device.update_attributes(params[:device])
			@message = '<font color="green">Device wurde gespeichert</font>'
		else
			@message = 'FEHLER'
		end
		page.replace_html "dv_usernotice", @message

		if update_port == 1
			html_id = "port3_#{@device.id}"

			page.replace_html "#{html_id}", :partial => "shared/port_listbox", :locals => {:show => "link", :opt => 3}
		end
	end
  end

	def create
		@kreuzschiene = Kreuzschiene.find(params[:id])
		@kreuzschiene.create_io
		flash[:notice] = 'Kreuzschiene wurde angelegt'

		respond_to do |format|
			format.html { redirect_to :controller=>'kreuzschienes', :action => "edit", :id => @kreuzschiene }
		end
	end

	def add_row
		nums = (1..512).to_a
	        @families = Family.find(:all)
		if !nums.include? params[:row_nr].to_i || params[:row_nr].blank?
			render :update do |page|
				page.replace_html "add_row_msg", "<font style='color:red'>Bitte geben Sie eine gültige Zeilennummer</font>"
			end
		else
			line = params[:row_nr].to_i
			input = params[:inputs].to_i
			output = params[:outputs].to_i
			kv_nr = params[:kv_id].to_i
			cnt = 0

			@kreuzschiene = Kreuzschiene.find(kv_nr)
			@tally = getTallyCollection
			@page = params[:page]

			if @page == "quellen"
				rows = input-line
				@sources = Source.find(:all, :conditions => ["kreuzschiene_id =? AND intnummer >= ?",kv_nr, line], :limit => rows, :order => "intnummer" )

				@new_row = Source.find(:first, :conditions => ["kreuzschiene_id =? AND intnummer = ?",kv_nr, line])
				@new_row.update_attributes(:name4stellig => nil, :name5stellig => nil, :char6 => nil, :char10 => nil, :cloneinput => nil, :tallybit => nil, :matrix => nil, :quelle => nil, :comment => nil, :mx_matrix => nil, :mx_senke => nil, :signal => nil, :subclass => nil, :component => nil, :subcomponent => nil)

				(rows).times{
					line+=1
					@next_row = Source.find(:first, :conditions => ["kreuzschiene_id =? AND intnummer = ?",kv_nr, line])
					@next_row.update_attributes(:name4stellig => @sources[cnt].name4stellig, :name5stellig => @sources[cnt].name5stellig, :char6 => @sources[cnt].char6, :char10 => @sources[cnt].char10, :cloneinput => @sources[cnt].cloneinput, :tallybit => @sources[cnt].tallybit, :matrix => @sources[cnt].matrix, :quelle => @sources[cnt].quelle, :comment => @sources[cnt].comment, :mx_matrix => @sources[cnt].mx_matrix, :mx_senke => @sources[cnt].mx_senke, :signal => @sources[cnt].signal, :subclass => @sources[cnt].subclass, :component => @sources[cnt].component, :subcomponent => @sources[cnt].subcomponent)
					cnt+=1
				}
			else
				rows = output-line
				@targets = Target.find(:all, :conditions => ["kreuzschiene_id =? AND intnummer >= ?",kv_nr, line ], :limit => rows, :order => "intnummer")
				@new_row = Target.find(:first, :conditions => ["kreuzschiene_id =? AND intnummer = ?",kv_nr, line])
				@new_row.update_attributes(:name4stellig => nil, :name5stellig => nil, :char6 => nil, :char10 => nil, :matrix => nil, :quelle => nil, :comment => nil, :mx_tallybit => nil, :mx_matrix => nil, :mx_quelle => nil, :signal => nil, :subclass => nil, :component => nil, :subcomponent => nil)

				(rows).times{
					line+=1
					@next_row = Target.find(:first, :conditions => ["kreuzschiene_id =? AND intnummer = ?",kv_nr, line])
					@next_row.update_attributes(:name4stellig => @targets[cnt].name4stellig, :name5stellig => @targets[cnt].name5stellig, :char6 => @targets[cnt].char6, :char10 => @targets[cnt].char10, :matrix => @targets[cnt].matrix, :quelle => @targets[cnt].quelle, :comment => @targets[cnt].comment, :mx_tallybit => @targets[cnt].mx_tallybit, :mx_matrix => @targets[cnt].mx_matrix, :mx_quelle => @targets[cnt].mx_quelle, :signal => @targets[cnt].signal, :subclass => @targets[cnt].subclass, :component => @targets[cnt].component, :subcomponent => @targets[cnt].subcomponent)
					cnt+=1
				}
			end

			update_references(@page, "add", params[:row_nr].to_i)


			render :update do |page|
				if @page == "quellen"
					if @kreuzschiene.kr_type == "MIXER" && !@kreuzschiene.ref_matrix_id.nil? && !@kreuzschiene.ref_matrix_id.blank?
						page.replace_html "dv_main", :partial => "mixer_quellentexte"
					elsif @kreuzschiene.kr_type == "MATRIX" && !@kreuzschiene.matrix_type.nil? &&  @kreuzschiene.matrix_type.title == "Lawo MONPL"
						page.replace_html "dv_main", :partial => "hlsd_quellentexte"
					else
						page.replace_html "dv_main", :partial => "quellentexte"
					end
				else
					if @kreuzschiene.kr_type == "MIXER"
						page.replace_html "dv_main", :partial => "mixer_senkentexte"
					elsif @kreuzschiene.kr_type == "MATRIX" && !@kreuzschiene.matrix_type.nil? && @kreuzschiene.matrix_type.title == "Lawo MONPL"
						page.replace_html "dv_main", :partial => "hlsd_senkentexte"
					else
						page.replace_html "dv_main", :partial => "senkentexte"
					end
				end
				page.hide "div-loader"
			end
		end
	end

	def remove_row
		@families = Family.find(:all)
		line = params[:row_nr].to_i
		input = params[:inputs].to_i
		output = params[:outputs].to_i
		kv_nr = params[:kv_id].to_i
		cnt = 0

		@kreuzschiene = Kreuzschiene.find(kv_nr)
		@tally = getTallyCollection
		@page = params[:page]

		if @page == "quellen"
			rows = input-line
			@sources = Source.find(:all, :conditions => ["kreuzschiene_id =? AND intnummer > ?",kv_nr, line], :limit => rows, :order => "intnummer" )

			(rows).times{

				@next_row = Source.find(:first, :conditions => ["kreuzschiene_id =? AND intnummer = ?",kv_nr, line])
				@next_row.update_attributes(:name4stellig => @sources[cnt].name4stellig, :name5stellig => @sources[cnt].name5stellig, :char6 => @sources[cnt].char6, :char10 => @sources[cnt].char10, :cloneinput => @sources[cnt].cloneinput, :tallybit => @sources[cnt].tallybit, :matrix => @sources[cnt].matrix, :quelle => @sources[cnt].quelle, :comment => @sources[cnt].comment, :mx_matrix => @sources[cnt].mx_matrix, :mx_senke => @sources[cnt].mx_senke, :signal => @sources[cnt].signal, :subclass => @sources[cnt].subclass, :component => @sources[cnt].component, :subcomponent => @sources[cnt].subcomponent)

				cnt+=1
				line+=1
			}
			@last_row = Source.find(:first, :conditions => ["kreuzschiene_id =? AND intnummer = ?",kv_nr, input])
			@last_row.update_attributes(:name4stellig => nil, :name5stellig => nil, :char6 => nil, :char10 => nil, :cloneinput => nil, :tallybit => nil, :matrix => nil, :quelle => nil, :comment => nil, :mx_matrix => nil, :mx_senke => nil, :signal => nil, :subclass => nil, :component => nil, :subcomponent => nil)
		else
			rows = output-line
			@targets = Target.find(:all, :conditions => ["kreuzschiene_id =? AND intnummer > ?",kv_nr, line], :limit => rows, :order => "intnummer" )

			(rows).times{

				@next_row = Target.find(:first, :conditions => ["kreuzschiene_id =? AND intnummer = ?",kv_nr, line])
				@next_row.update_attributes(:name4stellig => @targets[cnt].name4stellig, :name5stellig => @targets[cnt].name5stellig, :char6 => @targets[cnt].char6, :char10 => @targets[cnt].char10, :matrix => @targets[cnt].matrix, :quelle => @targets[cnt].quelle, :comment => @targets[cnt].comment, :mx_tallybit => @targets[cnt].mx_tallybit, :mx_matrix => @targets[cnt].mx_matrix, :mx_quelle => @targets[cnt].mx_quelle, :signal => @targets[cnt].signal, :subclass => @targets[cnt].subclass, :component => @targets[cnt].component, :subcomponent => @targets[cnt].subcomponent)

				cnt+=1
				line+=1
			}
			@last_row = Target.find(:first, :conditions => ["kreuzschiene_id =? AND intnummer = ?",kv_nr, output])
			@last_row.update_attributes(:name4stellig => nil, :name5stellig => nil, :char6 => nil, :char10 => nil, :matrix => nil, :quelle => nil, :comment => nil, :mx_tallybit => nil, :mx_matrix => nil, :mx_quelle => nil, :signal => nil, :subclass => nil, :component => nil, :subcomponent => nil)
		end

		update_references(@page, "remove", params[:row_nr].to_i)

		render :update do |page|
			if @page == "quellen"
				if @kreuzschiene.kr_type == "MIXER" && !@kreuzschiene.ref_matrix_id.nil? && !@kreuzschiene.ref_matrix_id.blank?
						page.replace_html "dv_main", :partial => "mixer_quellentexte"
				elsif @kreuzschiene.kr_type == "MATRIX" && !@kreuzschiene.matrix_type.nil? && @kreuzschiene.matrix_type.title == "Lawo MONPL"
					page.replace_html "dv_main", :partial => "hlsd_quellentexte"
				else
					page.replace_html "dv_main", :partial => "quellentexte"
				end
			else
				if @kreuzschiene.kr_type == "MIXER"
					page.replace_html "dv_main", :partial => "mixer_senkentexte"
				elsif @kreuzschiene.kr_type == "MATRIX" && !@kreuzschiene.matrix_type.nil? && @kreuzschiene.matrix_type.title == "Lawo MONPL"
					page.replace_html "dv_main", :partial => "hlsd_senkentexte"
				else
					page.replace_html "dv_main", :partial => "senkentexte"
				end
			end
		end
	end

	def update_references(section, operation, line)
		system_id = cookies[:system_id]
		kv_id = Kreuzschiene.find(:all, :conditions => ["system_id =?",system_id], :select => "id", :order => "id")
		@panels = Bediengeraet.find(:all, :conditions => ["system_id =? ", system_id], :select => "id, normalquellen_kv_id, sende_matrix_id, sende_senke_id, bdtype_id")

		if section=="quellen"
			@sources = Source.find(:all, :conditions => ["matrix =? AND quelle >=? AND kreuzschiene_id >=? AND kreuzschiene_id <=?", @kreuzschiene.intnummer, line, kv_id[0].id, kv_id[kv_id.size-1].id], :select => "id, quelle" )

			@targets = Target.find(:all, :conditions => ["mx_matrix =? AND mx_quelle >=? AND kreuzschiene_id >=? AND kreuzschiene_id <=?", @kreuzschiene.intnummer, line, kv_id[0].id, kv_id[kv_id.size-1].id], :select => "id, mx_quelle" )

			@clones = Source.find(:all, :conditions => ["kreuzschiene_id =? and cloneinput >=?", @kreuzschiene.id, line], :select => "id, cloneinput")

			if @kreuzschiene.intnummer == 1
				@bmes = Bme.find(:all, :conditions => ["system_id =? and source_id >=?", system_id, line], :select => "id, source_id")
			end

			if operation == "remove"
				@sources.each do |s|
					if s.quelle.to_i == line.to_i
						s.update_attributes(:quelle => "0")
					else
						quelle = s.quelle.to_i-1
						s.update_attributes(:quelle => quelle.to_s)
					end
				end

				@targets.each do |t|
					if t.mx_quelle.to_i == line.to_i
						t.update_attributes(:mx_quelle => "0")
					else
						mx_quelle = t.mx_quelle.to_i-1
						t.update_attributes(:mx_quelle => mx_quelle)
					end
				end

				@clones.each do |c|
					if c.cloneinput.to_i == line.to_i
						c.update_attributes(:cloneinput => "0")
					else
						ci = c.cloneinput.to_i-1
						c.update_attributes(:cloneinput => ci.to_s)
					end
				end

				if @kreuzschiene.intnummer == 1
					@bmes.each do |b|
						if b.source_id == line
							b.update_attributes(:source_id => 0)
						else
							s_id = b.source_id-1
							b.update_attributes(:source_id => s_id)
						end
					end
				end
			# Operation ADD section
			else
				@sources.each do |s|
					quelle = s.quelle.to_i+1
					s.update_attributes(:quelle => quelle.to_s)
				end

				@targets.each do |t|
					mx_quelle = t.mx_quelle.to_i+1
					t.update_attributes(:mx_quelle => mx_quelle)
				end

				@clones.each do |c|
					ci = c.cloneinput.to_i+1
					c.update_attributes(:cloneinput => ci.to_s)
				end


				if @kreuzschiene.intnummer == 1
					@bmes.each do |b|
						s_id = b.source_id+1
						b.update_attributes(:source_id => s_id)
					end
				end
			end

			# Update TypeSource Section
			@panels.each do |p|
				if p.bdtype_id == 3
					if p.normalquellen_kv_id == @kreuzschiene.id
						@ts = Typesource.find(:all, :conditions => ["bediengeraet_id =? AND matrix IS NULL and source_id >=?", p.id, line], :select => "id, source_id")
						@ts_m = Typesource.find(:all, :conditions => ["bediengeraet_id =? AND matrix =? and source_id >=?", p.id, @kreuzschiene.intnummer, line], :select => "id, source_id")
					else
						@ts = nil
						@ts_m = Typesource.find(:all, :conditions => ["bediengeraet_id =? AND matrix =? and source_id >=?", p.id, @kreuzschiene.intnummer, line], :select => "id, source_id")
					end
				else
					if p.normalquellen_kv_id == @kreuzschiene.id
						@ts = Typesource.find(:all, :conditions => ["bediengeraet_id =? and source_id >=?", p.id, line], :select => "id, source_id")
						@ts_m = nil
					end
				end

				if operation == "remove"
					# Update TypeSource Section : REMOVE
					if @ts
						@ts.each do |t|
							if t.source_id.to_i == line.to_i
								t.update_attributes(:source_id => 0)
							else
								s_id = t.source_id.to_i-1
								t.update_attributes(:source_id => s_id)
							end
						end
					end

					if @ts_m
						@ts_m.each do |t|
							if t.source_id.to_i == line.to_i
								t.update_attributes(:source_id => 0)
							else
								s_id = t.source_id.to_i-1
								t.update_attributes(:source_id => s_id)
							end
						end
					end
				else
					# Update TypeSource Section : ADD
					if @ts
						@ts.each do |t|
							s_id = t.source_id.to_i+1
							t.update_attributes(:source_id => s_id)
						end
					end

					if @ts_m
						@ts_m.each do |t|
							s_id = t.source_id.to_i+1
							t.update_attributes(:source_id => s_id)
						end
					end
				end
			end
		else
			# section : SENKEN MAIN

			@sources = Source.find(:all, :conditions => ["mx_matrix =? AND mx_senke >=? AND kreuzschiene_id >=? AND kreuzschiene_id <=?", @kreuzschiene.intnummer, line, kv_id[0].id, kv_id[kv_id.size-1].id], :select => "id, mx_senke" )

			@targets = Target.find(:all, :conditions => ["matrix =? AND quelle >=? AND kreuzschiene_id >=? AND kreuzschiene_id <=?", @kreuzschiene.intnummer, line, kv_id[0].id, kv_id[kv_id.size-1].id], :select => "id, quelle" )

			@umds = Umd.find(:all, :conditions => ["system_id =? and kreuzschiene_id =? and target_id >=?", system_id, @kreuzschiene.id, line ], :select => "id, target_id")

			@tallies = Tally.find(:all, :conditions => ["system_id =? and kreuzschiene_id =? and senke_id >=?", system_id, @kreuzschiene.intnummer, line], :select => "id, senke_id")

			if @kreuzschiene.intnummer == 1
				@bmes = Bme.find(:all, :conditions => ["system_id =? and peview_monitor >=?", system_id, line])
			end

			if operation == "remove"
				@sources.each do |s|
					if s.mx_senke.to_i == line.to_i
						s.update_attributes(:mx_senke => "0")
					else
						mx_senke = s.mx_senke.to_i-1
						s.update_attributes(:mx_senke => mx_senke)
					end
				end

				@targets.each do |t|
					if t.quelle.to_i == line.to_i
						t.update_attributes(:quelle => "0")
					else
						quelle = t.quelle.to_i-1
						t.update_attributes(:quelle => quelle.to_s)
					end
				end

				@umds.each do |u|
					if u.target_id == line
						u.update_attributes(:target_id => 0)
					else
						t_id = u.target_id-1
						u.update_attributes(:target_id => t_id)
					end
				end

				@tallies.each do |l|
					if l.senke_id == line
						l.update_attributes(:senke_id => 0)
					else
						s_id = l.senke_id-1
						l.update_attributes(:senke_id => s_id)
					end
				end

				if @kreuzschiene.intnummer == 1
					@bmes.each do |b|
						if b.peview_monitor == line
							b.update_attributes(:peview_monitor => 0)
						else
							pm = b.peview_monitor-1
							b.update_attributes(:peview_monitor => pm)
						end
					end
				end
			else
				@sources.each do |s|
					mx_senke = s.mx_senke.to_i+1
					s.update_attributes(:mx_senke => mx_senke)
				end

				@targets.each do |t|
					quelle = t.quelle.to_i+1
					t.update_attributes(:quelle => quelle.to_s)
				end

				@umds.each do |u|
					t_id = u.target_id+1
					u.update_attributes(:target_id => t_id)
				end

				@tallies.each do |l|
					s_id = l.senke_id+1
					l.update_attributes(:senke_id => s_id)
				end

				if @kreuzschiene.intnummer == 1
					@bmes.each do |b|
						pm = b.peview_monitor+1
						b.update_attributes(:peview_monitor => pm)
					end
				end
			end

			# Update TypeTarget Section
			@panels.each do |p|
				if p.bdtype_id == 3
					if p.normalquellen_kv_id == @kreuzschiene.id
						@ts = Typetarget.find(:all, :conditions => ["bediengeraet_id =? AND matrix IS NULL and target_id >=?", p.id, line], :select => "id, target_id")
						@ts_m = Typetarget.find(:all, :conditions => ["bediengeraet_id =? AND matrix =? and target_id >=?", p.id, @kreuzschiene.intnummer, line], :select => "id, target_id")
					else
						@ts = nil
						@ts_m = Typetarget.find(:all, :conditions => ["bediengeraet_id =? AND matrix =? and target_id >=?", p.id, @kreuzschiene.intnummer, line], :select => "id, target_id")
					end
				else
					if p.normalquellen_kv_id == @kreuzschiene.id
						@ts = Typetarget.find(:all, :conditions => ["bediengeraet_id =? and target_id >=?", p.id, line], :select => "id, target_id")
						@ts_m = nil
					end
				end

				if operation == "remove"
					if p.sende_matrix_id == @kreuzschiene.intnummer && p.sende_senke_id >= line
						if p.sende_senke_id == line
							p.update_attributes(:sende_senke_id => 0)
						else
							p.update_attributes(:sende_senke_id => (p.sende_senke_id-1))
						end
					end

					# Update Typetarget Section : REMOVE
					if @ts
						@ts.each do |t|
							if t.target_id.to_i == line.to_i
								t.update_attributes(:target_id => 0)
							else
								t_id = t.target_id.to_i-1
								t.update_attributes(:target_id => t_id)
							end
						end
					end

					if @ts_m
						@ts_m.each do |t|
							if t.target_id.to_i == line.to_i
								t.update_attributes(:target_id => 0)
							else
								t_id = t.target_id.to_i-1
								t.update_attributes(:target_id => t_id)
							end
						end
					end
				else
					if p.sende_matrix_id == @kreuzschiene.intnummer && p.sende_senke_id >= line
						p.update_attributes(:sende_senke_id => (p.sende_senke_id+1))
					end

					# Update Typetarget Section : ADD
					if @ts
						@ts.each do |t|
							t_id = t.target_id.to_i+1
							t.update_attributes(:target_id => t_id)
						end
					end

					if @ts_m
						@ts_m.each do |t|
							t_id = t.target_id.to_i+1
							t.update_attributes(:target_id => t_id)
						end
					end
				end
			end
		end
	end

	def getMixerQuelle
		@system = System.find(cookies[:system_id])
		@kreuzschiene = Kreuzschiene.find(params[:kv_id])
		@kreuzschiene.update_attributes(:ref_matrix_id => params[:matrix_id])

		if !@kreuzschiene.ref_matrix_id.nil? && !@kreuzschiene.ref_matrix_id.blank?
			@ref_kr = Kreuzschiene.find(@kreuzschiene.ref_matrix_id)
			@setups = Source.find_all_by_kreuzschiene_id(@ref_kr.id, :order => "intnummer", :limit => @ref_kr.input)

			cnt = 0
			@kreuzschiene.getSources.each do |@source|
				val = @setups[cnt]
				if val
					@source.update_attributes(:name4stellig => val.name4stellig, :name5stellig => val.name5stellig, :char6 => val.char6, :char10 => val.char10, :comment => val.comment, :cloneinput => val.cloneinput, :matrix => val.matrix, :quelle => val.quelle, :tallybit => val.tallybit)
				end
				cnt+=1
			end

			render :update do |page|
				page.replace_html "dv_main", :partial => "mixer_quellentexte"
				page.replace_html "add_row_msg", "Geschehen"
			end
		else
			@tally = getTallyCollection
			@page = "quellen"

			render :update do |page|
				page.replace_html "dv_main", :partial => "quellentexte"
				page.replace_html "add_row_msg", "Geschehen"
			end
		end
	end

	def loadCSV
		@kv_id = params[:kv_id]
		@page = params[:page]

		render :update do |page|
			page.replace_html "csv_container", :partial => "load_csv"
		end
	end

	def loadcsv_stagetek
		@kv_id = params[:kv_id]
		render :update do |page|
			page.replace_html "csv_container_stagetek", :partial => "loadstagetek_csv"
		end
	end

	def importCSV
		@system = System.find(cookies[:system_id])
		@kreuzschiene = Kreuzschiene.find(params[:kv_id])

		if !params[:upload]['datafile'].blank?
			file_name = params[:upload]['datafile'].original_filename
			if file_name.to_s.slice(-4,4) == ".csv"
				post = Datafile.save(params[:upload])

				@page = params[:page]
				@tally = getTallyCollection

				@setups = []

				CSV.open('conf/'+file_name, 'r', ',') do |row|
					if row[0]
					        if row[0].include?(";")
                                                  row=  row[0].split(';').flatten
                                                end
						@setups << row
					end
				end
         #                       render :text => @setups.inspect and return false
				File.delete('conf/'+file_name)
				cnt = 0
				msg = ""

				if @page == "quellen"
					@kreuzschiene.getSources.each do |@source|
						val = @setups[cnt]
						if val
							if @kreuzschiene.kr_type == "MATRIX" && !@kreuzschiene.matrix_type.nil? && @kreuzschiene.matrix_type.title == "Lawo MONPL"
								signal = SignalQuellen.getSignalByTitle(val[1].strip)
								if signal.nil? || signal.blank?
									sgn = nil
									msg << "#{val[1].strip}, "
								else
									sgn = signal.intnummer
								end
								check_csv_column(val.size, val, 'Lawo')
								@source.update_attributes(:signal => sgn, :subclass => val[2].to_i, :component => val[3].to_i, :subcomponent => val[4].to_i, :name4stellig => val[5], :name5stellig => val[6], :char6 => val[7], :char10 => val[8], :comment => val[9], :cloneinput => nil, :matrix => nil, :quelle => nil, :tallybit => nil, :mx_matrix => nil, :mx_senke => nil)
							else
								check_csv_column(val.size, val, '')
								@source.update_attributes(:name4stellig => val[1], :name5stellig => val[2], :char6 => val[3], :char10 => val[4], :comment => val[5], :cloneinput => nil, :matrix => nil, :quelle => nil, :tallybit => nil, :mx_matrix => nil, :mx_senke => nil)
							end
						else
							@source.update_attributes(:signal => nil, :subclass => nil, :component => nil, :subcomponent => nil, :name4stellig => nil, :name5stellig => nil, :char6 => nil, :char10 => nil, :comment => nil, :cloneinput => nil, :matrix => nil, :quelle => nil, :tallybit => nil, :mx_matrix => nil, :mx_senke => nil)
						end
						cnt+=1
					end
				else
					@kreuzschiene.getTargets.each do |@target|
						val = @setups[cnt]
						if val
							if @kreuzschiene.kr_type == "MATRIX" && !@kreuzschiene.matrix_type.nil? && @kreuzschiene.matrix_type.title == "Lawo MONPL"
								signal = SignalSenken.getSignalByTitle(val[1].strip)
								if signal.nil? || signal.blank?
									sgn = nil
									msg << "#{val[1].strip}, "
								else
									sgn = signal.intnummer
								end
								check_csv_column(val.size, val, 'Lawo')
								@target.update_attributes(:signal => sgn, :subclass => val[2].to_i, :component => val[3].to_i, :subcomponent => val[4].to_i, :name4stellig => val[5], :name5stellig => val[6], :char6 => val[7], :char10 => val[8], :comment => val[9], :matrix => nil, :quelle => nil, :mx_tallybit => nil, :mx_matrix => nil, :mx_quelle => nil)
							else
								check_csv_column(val.size, val, '')
								@target.update_attributes(:name4stellig => val[1], :name5stellig => val[2], :char6 => val[3], :char10 => val[4], :comment => val[5], :matrix => nil, :quelle => nil, :mx_tallybit => nil, :mx_matrix => nil, :mx_quelle => nil)
							end
						else
							@target.update_attributes(:signal => nil, :subclass => nil, :component => nil, :subcomponent => nil, :name4stellig => nil, :name5stellig => nil, :char6 => nil, :char10 => nil, :comment => nil, :matrix => nil, :quelle => nil, :mx_tallybit => nil, :mx_matrix => nil, :mx_quelle => nil)
						end
						cnt+=1
					end
				end

				message = ""
				message = "<font style='color:red;'>#{msg} not matching to signal names</font>" if msg!=""
				flash[:message] = message
			else
				flash[:message] = "<font style='color:red;'>Bitte laden CSV-Datei</font>"
			end
		else
			flash[:message] = "<font style='color:red;'>Bitte wählen Sie eine Datei</font>"
		end

#		CSV.remove('conf/'+file_name)
		redirect_to :back

	end

	def importCSV_stagetek_old
		data = params[:upload][:datafile].read

		data_arr = data.split("[OUTPUT]")

		data_arr_new = data_arr[0].split("[INPUT]")
		input_arr = data_arr_new[1].split("\r\n")
		output_arr = data_arr[1].split("\r\n")
		Source.delete_all(["kreuzschiene_id = ?",params[:kv_id]])
		i=0
		input_arr.size.times do
			if i > 0
				input_data = input_arr[i].split(" ")
				if input_data.size==5
					comment = input_data[3].to_s+" "+input_data[4].to_s
					input_val = input_data[0].split("=")
					char10 = input_val[1]+" "+input_data[1]+" "+input_data[2]
					real_input = input_val[0]
				elsif input_data.size==4
					comment = input_data[2].to_s+" "+input_data[3].to_s
					input_val = input_data[0].split("=")
					char10 = input_val[1]+" "+input_data[1]
					real_input = input_val[0]
				elsif input_data.size==3 && is_numeric?(input_data[2])
					comment = input_data[1].to_s+" "+input_data[2].to_s
					input_val = input_data[0].split("=")
					char10 = input_val[1]
					real_input = input_val[0]
				elsif input_data.size==3 && !is_numeric?(input_data[2])
					comment = input_data[2]
					input_val = input_data[0].split("=")
					render :text => input_val.inspect and return false
					char10 = input_val[1].to_s +" "+input_data[1]
					real_input = input_val[0]
				elsif input_data.size==2
					comment = input_data[1]
					input_val = input_data[0].split("=")
					char10 = input_val[1]
					real_input = input_val[0]
				end

				@source = Source.new()
				@source.intnummer = i
				@source.nummer = i
				@source.kreuzschiene_id = params[:kv_id]
				@source.created_at = Time.now()
				@source.updated_at = Time.now()
				@source.char10 = char10
				@source.comment = comment
				@source.channel = 1
				@source.real_input = real_input
				@source.save
			end
		i+=1
		end

		Target.delete_all(["kreuzschiene_id = ?",params[:kv_id]])
		j=0
		output_arr.size.times do
			if j > 0
				output_data = output_arr[j].split(" ")
				if output_data.size==5
					comment = output_data[3].to_s+" "+output_data[4].to_s
					output_val = output_data[0].split("=")
					char10 = output_val[1]+" "+output_data[1]+" "+output_data[2]
					real_output = output_val[0]
				elsif output_data.size==4
					comment = output_data[2].to_s+" "+output_data[3].to_s
					output_val = output_data[0].split("=")
					char10 = output_val[1]+" "+output_data[1]
					real_output = output_val[0]
				elsif output_data.size==3 && is_numeric?(output_data[2])
					comment = output_data[1].to_s+" "+output_data[2].to_s
					output_val = output_data[0].split("=")
					char10 = output_val[1]
					real_output = output_val[0]
				elsif output_data.size==3 && !is_numeric?(output_data[2])
					comment = output_data[2]
					output_val = output_data[0].split("=")
					char10 = output_val[1].to_s+ " "+ output_data[1].to_s
					real_output = output_val[0]
				elsif output_data.size==2
					comment = output_data[1]
					output_val = output_data[0].split("=")
					char10 = output_val[1].to_s
					real_output = output_val[0]
				end

				@target = Target.new()
				@target.intnummer = j
				@target.nummer = j
				@target.kreuzschiene_id = params[:kv_id]
				@target.created_at = Time.now()
				@target.updated_at = Time.now()
				@target.char10 = char10
				@target.comment = comment
				@target.channel = 1
				@target.real_output = real_output
				@target.save
			end
		j+=1
		end
		redirect_to :action => 'edit', :id => params[:kv_id]
	end


	def importCSV_stagetek
		data = params[:upload][:datafile].read
		data = data.gsub(/\r\n/,"\n")
		data_arr = data.split("[OUTPUT]")

		data_arr_new = data_arr[0].split("[INPUT]")
		input_arr = data_arr_new[1].split("\n")
		output_arr = data_arr[1].split("\n")
		Source.delete_all(["kreuzschiene_id = ?",params[:kv_id]])
		i=0
		input_arr.size.times do		
			if i > 0
				if !input_arr[i].nil? && input_arr[i]!='\n ' && !input_arr[i].blank?
					input_data = input_arr[i].strip.split("=.")
					real_input = input_data[0]
					comment = input_data[1].gsub("\n","") if !input_data[1].nil?
					char10 = input_data[1][0,10].gsub("\n","") if !input_data[1].nil?
					@source = Source.new()
					@source.intnummer = i
					@source.nummer = i
					@source.kreuzschiene_id = params[:kv_id]
					@source.created_at = Time.now()
					@source.updated_at = Time.now()
					@source.char10 = char10
					@source.name5stellig = char10
					@source.name4stellig = char10
					@source.char6 = char10
					@source.comment = comment
					@source.channel = 1
					@source.real_input = real_input
					@source.save
				end
			end
		i+=1
		end
		Target.delete_all(["kreuzschiene_id = ?",params[:kv_id]])
		j=0
		output_arr.size.times do
			if j > 0
				if !output_arr[i].nil? && output_arr[i]!='\n' && !output_arr[i].blank?
					output_data = output_arr[j].strip.split("=.")
					comment = output_data[1].gsub("\n","") if !output_data[1].nil?
					char10 = output_data[1][0,10].gsub("\n","") if !output_data[1].nil?
					real_output = output_data[0]

					@target = Target.new()
					@target.intnummer = j
					@target.nummer = j
					@target.kreuzschiene_id = params[:kv_id]
					@target.created_at = Time.now()
					@target.updated_at = Time.now()
					@target.char10 = char10
					@target.name5stellig = char10
					@target.name4stellig = char10
					@target.char6 = char10
					@target.comment = comment
					@target.channel = 1
					@target.real_output = real_output
					@target.save
				end
			end
		j+=1
		end
		redirect_to :action => 'edit', :id => params[:kv_id]
	end

	def set_to_default
		@families = Family.find(:all)
		@system = System.find(cookies[:system_id])
		@kreuzschiene = Kreuzschiene.find(params[:kv_id])
		@page = params[:page]

		if @page=="quellen"
			@kreuzschiene.getSources.each do |@source|
				val = "I#{formatnumber3(@source.intnummer)}"
				@source.update_attributes(:name4stellig => val, :name5stellig => val, :char6 => val, :char10 => val, :comment => val)
			end
		else
			@kreuzschiene.getTargets.each do |@target|
				val = "O#{formatnumber3(@target.intnummer)}"
				@target.update_attributes(:name4stellig => val, :name5stellig => val, :char6 => val, :char10 => val, :comment => val)
			end
		end

		#render :text => @kreuzschiene.getSources.size.inspect and return false
		render :update do |page|
			if @page == "quellen"
				if @kreuzschiene.kr_type == "MIXER" && !@kreuzschiene.ref_matrix_id.nil? && !@kreuzschiene.ref_matrix_id.blank?
					page.replace_html "dv_main", :partial => "mixer_quellentexte"
				else
					page.replace_html "dv_main", :partial => "quellentexte"
				end
			else
				if @kreuzschiene.kr_type == "MIXER"
					page.replace_html "dv_main", :partial => "mixer_senkentexte"
				else
					page.replace_html "dv_main", :partial => "senkentexte"
				end
			end
			page.hide "div-loader"
		end
	end

	def formatnumber3(nbr)
		return "000" if nbr.nil? || nbr.blank?
		return "00" + nbr.to_s if nbr.to_i<10
		return "0" + nbr.to_s if nbr.to_i<100
		return nbr.to_s
	end

	def matrix_types
		@m_types = MatrixType.getMatrixTypes
	end

	def update_matrix_type
		@m_types = MatrixType.find_by_intnummer(params[:matrix_type][:intnummer])
		if @m_types.update_attributes(params[:matrix_type])
			flash[:message] = "<font style='color:green;'> Matrix-Typ erfolgreich aktualisiert </font>"
		else
			flash[:message] = "<font style='color:red;'> Matrix-Typ wird nicht aktualisiert </font>"
		end

		redirect_to :back
	end

	def create_matrix_type
		MatrixType.new(params[:matrix_type]).save
		flash[:message] = "<font style='color:green;'> Matrix-Typ erfolgreich gespeichert </font>"

		redirect_to :back
	end

	def delete_matrix_type
		@m_types = MatrixType.find_by_intnummer(params[:id])
		@m_types.destroy
		flash[:message] = "<font style='color:green;'> Matrix-Typ erfolgreich entfernt </font>"

		redirect_to :back
	end

	def is_numeric?(obj)
	   	obj.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
	end

	def check_csv_column(col, val, matrix_type)
		if matrix_type == 'Lawo'
			if col == 6
			elsif col == 5
				val[5] = val[4]
				val[6] = val[4]						
				val[7] = val[4]			
				val[8] = val[4]			
				val[9] = val[4]			
			elsif col == 4
				val[4] = val[3]
				val[5] = val[3]			
				val[6] = val[3]						
				val[7] = val[3]			
				val[8] = val[3]			
				val[9] = val[3]			
			elsif col == 3
				val[3] = val[2]
				val[4] = val[2]
				val[5] = val[2]			
				val[6] = val[2]						
				val[7] = val[2]			
				val[8] = val[2]			
				val[9] = val[2]			
			elsif col == 2
				val[2] = val[1]
				val[3] = val[1]
				val[4] = val[1]
				val[5] = val[1]			
				val[6] = val[1]						
				val[7] = val[1]			
				val[8] = val[1]			
				val[9] = val[1]			
			end
		else
			if col == 6
			elsif col == 5
				val[5] = val[4]			
			elsif col == 4
				val[4] = val[3]
				val[5] = val[3]			
			elsif col == 3
				val[3] = val[2]
				val[4] = val[2]
				val[5] = val[2]			
			elsif col == 2
				val[2] = val[1]
				val[3] = val[1]
				val[4] = val[1]
				val[5] = val[1]			
			end
		end
	end
end

