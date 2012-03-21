class BediengeraetsController < ApplicationController

  layout "application", :except=>['update', 'update_senke', 'update_sende_values']
  # GET /bediengeraets/1
  # GET /bediengeraets/1.xml
  def show

	@system = System.find(cookies[:system_id])
	@bediengeraete = Bediengeraet.find_all_by_system_id(cookies[:system_id])
	@units = get_units

	if session[:display].nil? || session[:display]=='name' then
		@bdtypes = Bdtype.find(:all).map {|u| [u.name, u.id]}
	else
		@bdtypes = Bdtype.find(:all).map {|u| [u.id, u.id]}
	end

	respond_to do |format|
		format.html # show.html.erb
	end

  end

  # typ-dispatcher
  def typeshow
	@system = System.find(cookies[:system_id])
	@bediengeraet = Bediengeraet.getBediengeraet(params[:id], @system)
	if @bediengeraet.bdtype_id > 0 then
		redirect_to :controller=>'typ' + @bediengeraet.bdtype_id.to_s + 's', :action => 'show', :id=>@bediengeraet.intnummer
	else
		redirect_to :action => 'show'
	end
  end

  # PUT /bediengeraets/1
  # PUT /bediengeraets/1.xml
  def update

	# muss der Typ neu definiert werden?
	recreate = false
	unit = params[:bediengeraet][:unit]
	port = params[:bediengeraet][:port]
	update_port = 0

	@bediengeraet = Bediengeraet.find(params[:id])
	@message = nil
#render :text => port.inspect and return false
#	if !port.nil? && !port.blank? && port.to_i != @bediengeraet.port
	if !port.nil?  && port.to_i != @bediengeraet.port
		html_id = "port4_#{@bediengeraet.id}"
		opt = 4
		update_port = 1
	end

	checkomat = Bediengeraet.pu_free?(params[:bediengeraet][:port], params[:bediengeraet][:unit], @bediengeraet.system_id, @bediengeraet.id, nil)
	if checkomat==false then
	  @message = ("<font color='red'>Die Kombination Unit=" + params[:bediengeraet][:unit] + " Port=" + params[:bediengeraet][:port] + " ist bereits belegt, bitte ändern</font>")
	  return
	end

	unless params[:bediengeraet][:bdtype_id].to_s==@bediengeraet.bdtype_id.to_s then
	  Typesource.destroy_all(:bediengeraet_id=>params[:id])
	  logger.info "changing bd from " + params[:bediengeraet][:bdtype_id].to_s + " to " + @bediengeraet.bdtype_id.to_s
	  recreate = true
	end
	params[:bediengeraet][:ip] = getIpFormat(params[:bediengeraet][:ip])
	@bediengeraet.update_attributes(params[:bediengeraet])

	if @bediengeraet.name8stellig.nil? or @bediengeraet.name8stellig=="" or recreate==true then
	  logger.info "recreating typ" + @bediengeraet.bdtype_id.to_s

	  #@bediengeraet.update_attribute(:nummer, "BD_0" + @bediengeraet.intnummer)
	  @bediengeraet.update_attribute(:bdtype_id, params[:bediengeraet][:bdtype_id])

	  if @bediengeraet.bdtype_id==1 then
		Typ1.create(params[:id], cookies[:system_id])
	  elsif @bediengeraet.bdtype_id==2 then
		Typ2.create(params[:id], cookies[:system_id])
	  elsif @bediengeraet.bdtype_id==3 then
		Typ3.create(params[:id], cookies[:system_id])
	  elsif @bediengeraet.bdtype_id==4 then
		Typ4.create(params[:id], cookies[:system_id])
	  elsif @bediengeraet.bdtype_id==5 then
		Typ5.create(params[:id], cookies[:system_id])
	  end

	end

	#respond_to do |format|
	if params[:bediengeraet][:bdtype_id].to_i>0 then
		@message = '<font color="green">Bediengeraet wurde aktualisiert.</font>'
	else
		@message = '<font color="red">Bediengeraet unvollständig, definieren Sie alle Felder!</font>'
	end
	@message = (@message || '<font color="green">Bediengeraet wurde gespeichert</font>')


	render :update do |page|
		page.replace_html "bd_usernotice", @message

		if update_port == 1
			page.replace_html "#{html_id}", :partial => "shared/port_listbox", :locals => {:show => "link", :opt => opt}
		end
	end

  end

	def copy
		if params[:copy].nil?
			copy_quelle = 0
			copy_splitquellen = 0
			copy_senken = 0
		else
			params[:copy][:quelle].nil? ? copy_quelle = 0 : copy_quelle = 1
			params[:copy][:splitquellen].nil? ? copy_splitquellen = 0 : copy_splitquellen = 1
			params[:copy][:senken].nil? ? copy_senken = 0 : copy_senken = 1
		end

		system_id = cookies[:system_id]
		@system = System.find(system_id)

		if !params[:von].nil? && !params[:von].blank? && !params[:nach].nil? && !params[:nach].blank?
			von = Bediengeraet.getBediengeraet(params[:von].to_i, system_id)
			nach = Bediengeraet.getBediengeraet(params[:nach].to_i, system_id)

			if nach.name8stellig.nil? or nach.name8stellig=="" then
				nach.update_attribute(:name8stellig,'copy ' + von.intnummer.to_s)
			end

			if nach.name4stellig.nil? or nach.name4stellig=="" then
				nach.update_attribute(:name4stellig,'c' + von.intnummer.to_s)
			end

			nach.update_attribute(:bdtype_id, von.bdtype_id)
			nach.update_attribute(:normalquellen_kv_id, von.normalquellen_kv_id)
			nach.update_attribute(:splitquellen_kv_id, von.splitquellen_kv_id)
			nach.save

			# Aufräumen
			Typesource.destroy_all(:bediengeraet_id=>nach.id)
			Typetarget.destroy_all(:bediengeraet_id=>nach.id)

			@system.createBDTypDummy(nach.id, von.bdtype_id)

			ts_n = Typesource.find_all_by_bediengeraet_id_and_sourcetype(von.id, "normal")
			ts_s = Typesource.find_all_by_bediengeraet_id_and_sourcetype(von.id, "split")

			tt = Typetarget.find_all_by_bediengeraet_id(von.id)

			if copy_quelle == 1
				ts_n.each do |source|
					temp = Typesource.find_by_bediengeraet_id_and_tasten_id_and_sourcetype(nach.id, source.tasten_id, "normal")
					temp.source_id = source.source_id
					temp.sourcetype = "normal"
					temp.matrix = source.matrix
					temp.save
				end
			end

			if [2,3,5].include? von.bdtype_id
				if copy_splitquellen == 1
					ts_s.each do |source|
						temp = Typesource.find_by_bediengeraet_id_and_tasten_id_and_sourcetype(nach.id, source.tasten_id, "split")
						temp.source_id = source.source_id
						temp.sourcetype = "split"
						temp.save
					end
				end
			else
				ts_s.each do |source|
					temp = Typesource.find_by_bediengeraet_id_and_tasten_id_and_sourcetype(nach.id, source.tasten_id, "split")
					temp.source_id = source.source_id
					temp.sourcetype = "split"
					temp.matrix = source.matrix
					temp.save
				end
			end

			if copy_senken == 1
				tt.each do |target|
					temp = Typetarget.find_by_bediengeraet_id_and_tasten_id(nach.id, target.tasten_id)
					temp.target_id = target.target_id
					temp.save
				end
			end

			respond_to do |format|
				flash[:notice] = "Bediengeraet " + von.intnummer.to_s + " wurde nach " + nach.intnummer.to_s + " kopiert"
				format.html { redirect_to(:controller=>'bediengeraets', :action=>'show') }
			end
		else
			respond_to do |format|
				flash[:notice] = "fehlende Daten - 'nach und von'"
				format.html { redirect_to(:controller=>'bediengeraets', :action=>'show') }
			end
		end
	end

  # aus dem Typ heraus
  def update_normalquelle
	@panel = Bediengeraet.find(params[:id])
	@panel.update_attributes(params[:bediengeraets])

	respond_to do |format|
		#if session[:display].nil? || session[:display]=='name' then
		#  action ="show_name"
		#else
		  action ="show"
		#end
		format.html { redirect_to(:controller=>'typ' + @panel.bdtype_id.to_s + 's', :action => action, :id=>@panel.intnummer) }
	end
  end

  def getKopierenOptions
	@system = System.find(cookies[:system_id])
	@bd = Bediengeraet.getBediengeraet(params[:bd_nr].to_i, @system )

	render :update do |page|
		page.replace_html "grp_options", :partial => "kopieren_options", :locals => {:bdtype_id => @bd.bdtype_id}
	end
  end

  def update_senke
	#render :text => params.inspect and return false
	@system = System.find(cookies[:system_id])
	@panel = Bediengeraet.find(params[:id])
	@panel.update_attributes(:sende_matrix_id => params[:bediengeraets][:sende_matrix_id])
	if !params[:bediengeraets][:sende_matrix_id].blank?
		@kv_senke = Kreuzschiene.getMatrix(params[:bediengeraets][:sende_matrix_id], @system)
		@matrix = @kv_senke.intnummer
		@sn = Target.find_all_by_kreuzschiene_id(@kv_senke.id, :order=>"nummer", :limit => @kv_senke.input).map {|u| [u.name5stellig, u.intnummer]}
	end
  end

  def update_sende_values
	@system = System.find(cookies[:system_id])
	@panel = Bediengeraet.find(params[:id])
	@panel.update_attributes(:sende_matrix_id => params[:bediengeraets][:sende_matrix_id], :sende_senke_id => params[:bediengeraets][:sende_senke_id])

	@kv_senke = Kreuzschiene.getMatrix(params[:bediengeraets][:sende_matrix_id], @system)
	@sn = Target.find_all_by_kreuzschiene_id(@kv_senke.id, :order=>"nummer", :limit => @kv_senke.input).map {|u| [u.name5stellig, u.intnummer]}
  end

  def clear_section

	@panel = Bediengeraet.find(params[:id])

	if @panel.normalquellen_kv_id.nil? then
		flash[:notice] = '<font color="red">Es wurde keine Kreuzschiene ausgew&auml;hlt</font>'
		redirect_to :action=>'show', :id=>@panel.intnummer
		return
	end

	kv_matrix = Kreuzschiene.getMatrix(@panel.normalquellen_kv_id, @panel.system_id)
	matrix = kv_matrix.intnummer
	# Quellen anlegen
	if params[:part]=="quellen" then
		@panel.normalsources.each do |x| x.destroy end
		c=0
		Global::TYP3_NORMALQUELLEN.times  {
			c=c+1
			Typesource.new(:tasten_id => c, :bediengeraet_id => @panel.id, :source_id => 0, :sourcetype => 'normal', :matrix => nil).save
		}
	end

	if params[:part]=="splits" then
		@panel.splitsources.each do |x| x.destroy end
		c=0
		Global::TYP3_SPLITQUELLEN.times  {
			c=c+1
			Typesource.new(:tasten_id=>c, :bediengeraet_id=>@panel.id, :source_id=>0, :sourcetype=>'split', :matrix => nil).save
		}
	end

	if params[:part]=="senken" then
		@panel.typetargets.each do |x| x.destroy end
		c=0
		d=0
		Global::TYP3_SENKEN.times  {
			c=c+1
			if [16,32,48,64,80].include? c
				c=c+1
			end
			Typetarget.new(:tasten_id=>c, :bediengeraet_id=>@panel.id, :target_id=>0, :matrix => nil).save
		}
	end

	flash[:notice] = '1:1 Belegung durchgef&uuml;hrt'

	redirect_to :back

  end



end

