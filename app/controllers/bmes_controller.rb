class BmesController < ApplicationController

  # GET /bmes/1
  # GET /bmes/1.xml
  def show
	@system = System.find(cookies[:system_id])
	@bmes = Bme.find_all_by_system_id(@system)
	kv = Kreuzschiene.find_by_intnummer_and_system_id(0, @system)
	if session[:display].nil? || session[:display]=='name' then
		@kv = Source.find(:all, :conditions=>['kreuzschiene_id=?', kv.id], :limit => kv.input, :order => 'intnummer ASC').map {|u| [u.name4stellig, u.intnummer]}
		@sn = Target.find(:all, :conditions=>['kreuzschiene_id=?', kv.id], :limit => kv.output, :order => 'intnummer ASC').map {|u| [u.name4stellig, u.intnummer]}
	else
		@kv = Source.find(:all, :conditions=>['kreuzschiene_id=?', kv.id], :limit => kv.input, :order => 'intnummer ASC').map {|u| [u.intnummer, u.intnummer]}
		@sn = Target.find(:all, :conditions=>['kreuzschiene_id=?', kv.id], :limit => kv.output, :order => 'intnummer ASC').map {|u| [u.intnummer, u.intnummer]}
	end
	respond_to do |format|
		if session[:display].nil? || session[:display]=='name' then
			action ="show_name"
		else
			action ="show"
		end
		format.html { render :action => action, :id=>@bmes }
	end
  end

  # PUT /bmes/1
  # PUT /bmes/1.xml
  def update
	@bme = Bme.find(params[:id])
	@bme.update_attributes(params[:bme])

	render :update do |page|

	end
  end


  def mixer_template
	@system_id = cookies[:system_id]
	#@tpls = MixerTemplate.find_all_by_system_id(@system_id)
	@tpls = MixerTemplate.find(:all)
  end


  def update_mixer_template
	@tpl = MixerTemplate.find(params[:id])

	respond_to do |format|
		if @tpl.update_attributes(params[:mixer_template])
			flash[:notice] = 'Mixer template geändert.'
		end
		format.html { redirect_to :action => "mixer_template" }
	end
  end


  def create_mixer_template
	@tpl = MixerTemplate.new
		@tpl.intnummer = params[:mixer_template][:intnummer]
		@tpl.name = params[:mixer_template][:name]
		@tpl.system_id = params[:mixer_template][:system_id]
		@tpl.input = 1
		@tpl.output = 1
	@tpl.save

	@setup = MixerTemplateSetup.new(:intnummer => 1, :mixer_template_id => @tpl.intnummer, :name5stellig => nil, :name4stellig => nil, :char6 => nil, :char10 => nil, :comment => nil, :tallybit => nil, :system_id => @tpl.system_id).save

	respond_to do |format|
		format.html { redirect_to :action => "mixer_template" }
	end
  end


  def setChangeAll
	if params[:opt] == "yes"
		session[:TEMPLATE_CHANGE_ALL] = 1 
	else
		session[:TEMPLATE_CHANGE_ALL] = 0
	end

	render :update do |page|
	end
  end


  def mixer_template_setup
        @system = System.find(cookies[:system_id])
	#@tpl = MixerTemplate.find_by_intnummer_and_system_id(params[:id],@system)
	@tpl = MixerTemplate.find_by_intnummer(params[:id])
	@setups = MixerTemplateSetup.find_all_by_mixer_template_id(params[:id])
	#@tally = getSimulatedDestinationCollection
	session[:TEMPLATE_CHANGE_ALL] = 0
  end


  def update_mixer_template_setup
	@setup = MixerTemplateSetup.find(params[:id])

	render :update do |page|
		if session[:TEMPLATE_CHANGE_ALL] == 1
			if @setup.name4stellig != params[:mixer_template_setup][:name4stellig]
				params[:mixer_template_setup][:name5stellig] = params[:mixer_template_setup][:name4stellig]
				params[:mixer_template_setup][:char6] = params[:mixer_template_setup][:name4stellig]
				params[:mixer_template_setup][:char10] = params[:mixer_template_setup][:name4stellig]
				params[:mixer_template_setup][:comment] = params[:mixer_template_setup][:name4stellig]

			elsif @setup.name5stellig != params[:mixer_template_setup][:name5stellig]
				params[:mixer_template_setup][:char6] = params[:mixer_template_setup][:name5stellig]
				params[:mixer_template_setup][:char10] = params[:mixer_template_setup][:name5stellig]
				params[:mixer_template_setup][:comment]= params[:mixer_template_setup][:name5stellig]

			elsif @setup.char6 != params[:mixer_template_setup][:char6]
				params[:mixer_template_setup][:char10] = params[:mixer_template_setup][:char6]
				params[:mixer_template_setup][:comment] = params[:mixer_template_setup][:char6]

			elsif @setup.char10 != params[:mixer_template_setup][:char10]
				params[:mixer_template_setup][:comment] = params[:mixer_template_setup][:char10]

			end

			@setup.update_attributes(params[:mixer_template_setup])
			page["#{params[:id]}"]["mixer_template_setup_name5stellig"]['value'] = @setup.name5stellig
			page["#{params[:id]}"]["mixer_template_setup_char6"]['value'] = @setup.char6
			page["#{params[:id]}"]["mixer_template_setup_char10"]['value'] = @setup.char10
			page["#{params[:id]}"]["mixer_template_setup_comment"]['value'] = @setup.comment
		else
			@setup.update_attributes(params[:mixer_template_setup])
		end

	end
  end

  def update_template_io
	system_id = cookies[:system_id]
	@tpl = MixerTemplate.find_by_id(params[:id])
	opt = 0
	if params[:mixer_template][:output].nil? || params[:mixer_template][:output].blank?
		params[:mixer_template][:output] = 0
	end
	if !@tpl.output.nil? && !@tpl.output.blank?
		opt = 2 
	else
		opt = 1  # new entries in Mixer Template Setup
	end
	@tpl.update_attributes(params[:mixer_template])

	# Update values of input & output in Kreuzschiene
	Kreuzschiene.update_all ['input =?', @tpl.input], ['mixer_template_id =?', @tpl.intnummer]
	Kreuzschiene.update_all ['output =?', @tpl.output], ['mixer_template_id =?', @tpl.intnummer]

	if opt == 1

		nummer = 1
		@tally = getSimulatedDestinationCollection

		@tpl.output.times do |t|
			@setup = MixerTemplateSetup.new(:intnummer => nummer, :mixer_template_id => @tpl.intnummer, :name5stellig => nil, :name4stellig => nil, :char6 => nil, :char10 => nil, :comment => nil, :tallybit => nil, :system_id => system_id).save
			nummer += 1
		end

	elsif opt == 2

		last_nr = MixerTemplateSetup.maximum("intnummer", :conditions => ["mixer_template_id =?", @tpl.id]) || 0
		@tally = getSimulatedDestinationCollection

		if @tpl.output < last_nr
			# new < old 
			# Delete extra entries
			MixerTemplateSetup.destroy_all("mixer_template_id = #{@tpl.intnummer} AND intnummer > #{@tpl.output} AND system_id = #{system_id}")
		else
			# new > old 
			# Add extra entries
			(@tpl.output.to_i-last_nr).times do |t|
				last_nr += 1
				@setup = MixerTemplateSetup.new(:intnummer => last_nr, :mixer_template_id => @tpl.intnummer, :name5stellig => nil, :name4stellig => nil, :char6 => nil, :char10 => nil, :comment => nil, :tallybit => nil, :system_id => system_id).save
			end
		end

	end

	render :update do |page|
		if opt != 0
			@setups = MixerTemplateSetup.find_all_by_mixer_template_id(@tpl.intnummer)

			page.replace_html "setup_list", :partial => "template_setup"
		end
	end
  end

  def delete_mixer_template
  	system_id = cookies[:system_id]
	@tpl = MixerTemplate.find(params[:id])
	MixerTemplateSetup.destroy_all("mixer_template_id = #{@tpl.intnummer} AND system_id = #{system_id}")
	@tpl.destroy

	respond_to do |format|
		format.html { redirect_to :action => "mixer_template" }
	end
  end

  def update_bmes
	@mixter_template_setups = MixerTemplateSetup.find(:all, :group => 'mixer_template_id')
	@mixter_template_setups.each do |mts|
		@mts_template = MixerTemplateSetup.find(:all, :conditions => ["mixer_template_id = ?", mts.mixer_template_id])
		j=1
		@mts_template.each do |mt|
			@mts = MixerTemplateSetup.find(mt.id)
			@mts.update_attribute("intnummer", j)
		j+=1
		end
	end
  end
end
