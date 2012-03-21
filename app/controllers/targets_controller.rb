class TargetsController < ApplicationController

  layout "application", :except=>['dropdowns', 'kv_dropdowns', 'update']

  def update
	@target = Target.find(params[:id])
	update_quelle = 0
	update_mx_quelle = 0

	if !params[:target][:matrix].nil? && !params[:target][:matrix].blank? && @target.matrix.to_s != params[:target][:matrix]
	  update_quelle = 1
	end

	if !params[:target][:mx_matrix].nil? && !params[:target][:mx_matrix].blank? && @target.mx_matrix!= params[:target][:mx_matrix].to_i
	  update_mx_quelle = 1
	end

	render :update do |page|
	  if session[:SENKEN_CHANGE_ALL] == 1
		if @target.name4stellig != params[:target][:name4stellig]
		  params[:target][:name5stellig] = params[:target][:name4stellig]
		  params[:target][:char6] = params[:target][:name4stellig]
		  params[:target][:char10] = params[:target][:name4stellig]
		  params[:target][:comment] = params[:target][:name4stellig]

		  update_quelle = 1
		  id = params[:id]
		  kr_id = params[:kr_id]
		  char6 = params[:target][:char6]

		elsif @target.name5stellig != params[:target][:name5stellig]
		  params[:target][:char6] = params[:target][:name5stellig]
		  params[:target][:char10] = params[:target][:name5stellig]
		  params[:target][:comment] = params[:target][:name5stellig]

		  update_quelle = 1
		  id = params[:id]
		  kr_id = params[:kr_id]
		  char6 = params[:target][:char6]

		elsif @target.char6 != params[:target][:char6]
		  params[:target][:char10] = params[:target][:char6]
		  params[:target][:comment] = params[:target][:char6]

		  update_quelle = 1
		  id = params[:id]
		  kr_id = params[:kr_id]
		  char6 = params[:target][:char6]

		elsif @target.char10 != params[:target][:char10]
		  params[:target][:comment] = params[:target][:char10]

		end

		@target.update_attributes(params[:target])
		page["#{params[:id]}"]["target_name5stellig"]['value'] = @target.name5stellig
		page["#{params[:id]}"]["target_char6"]['value'] = @target.char6
		page["#{params[:id]}"]["target_char10"]['value'] = @target.char10
		page["#{params[:id]}"]["target_comment"]['value'] = @target.comment

		if update_quelle == 1
		  @kreuzschiene = Kreuzschiene.find(kr_id)
		  @quelle = Target.find_all_by_matrix_and_kreuzschiene_id(@kreuzschiene.name, kr_id)
		  @quelle_list = @kreuzschiene.getTargetQuelle 

		  @quelle.each do |c|
			@html = "<select class='ibtTableSelectBox' id='target_quelle' name='target[quelle]' onchange='document.getElementById(\"submitchangeitemt#{c.id}\").click();' >
				<option value='' >&nbsp;</option> "
				@quelle_list.each do |q|
					@html += "<option value='#{q.id}' #{c.quelle.to_s == q.id.to_s ? 'selected= \"selected\"' : nil}>#{id == q.id.to_s ? char6 : q.char6}</option>"
				end
			@html += "</select>"
			page.replace_html "target_#{c.id}", @html 
			@html = ""
		  end
		  update_quelle = 0
		end
	  else
		if @target.char6 != params[:target][:char6]
		  id = params[:id]
		  kr_id = params[:kr_id]
		  char6 = params[:target][:char6]
		  @target.update_attributes(params[:target])

		  @kreuzschiene = Kreuzschiene.find(kr_id)
		  @quelle = Target.find_all_by_matrix_and_kreuzschiene_id(@kreuzschiene.name, kr_id)
		  @quelle_list = @kreuzschiene.getTargetQuelle 

		  @quelle.each do |c|
			@html = "<select class='ibtTableSelectBox' id='target_quelle' name='target[quelle]' onchange='document.getElementById(\"submitchangeitemt#{c.id}\").click();' >
				<option value='' >&nbsp;</option> "
				@quelle_list.each do |q|
					@html += "<option value='#{q.id}' #{c.quelle.to_s == q.id.to_s ? 'selected=\"selected\"' : nil}>#{id == q.id.to_s ? char6 : q.char6}</option>"
				end
			@html += "</select>"
			page.replace_html "target_#{c.id}", @html 
			@html = ""
		  end
		else
		  @target.update_attributes(params[:target])
		end
	  end

	  if update_quelle == 1
		@page = "senken"
		prev_target = Target.find(@target.id-1)
		next_val = Option.getNextOption.value

		if prev_target && prev_target.matrix.to_i == @target.matrix.to_i
			if next_val == "N+1"
				@target.update_attributes(:quelle => prev_target.quelle.to_i+1)
			else
				@target.update_attributes(:quelle => prev_target.quelle)
			end
		else
			last_senke = Target.getLastQuelle(@target.kreuzschiene_id, @target.matrix)
			if last_senke && !last_senke.quelle.nil?
				if next_val == "N+1"
					@target.update_attributes(:quelle => (last_senke.quelle.to_i+1).to_s) 
				else
					@target.update_attributes(:quelle => last_senke.quelle) 
				end
			end
		end

		page.replace_html "target_#{@target.id}", :partial => "kreuzschienes/quelle_select", :locals => {:target => @target, :page => @page}
	  end

	  if update_mx_quelle == 1
		@page = "senken"
		prev_target = Target.find(@target.id-1)
		next_val = Option.getNextOption.value

		if prev_target && prev_target.mx_matrix == @target.mx_matrix
			if next_val == "N+1"
				@target.update_attributes(:mx_quelle => prev_target.mx_quelle+1)
			else
				@target.update_attributes(:mx_quelle => prev_target.mx_quelle)
			end
		else
			last_senke = Target.getLastSenke(@target.kreuzschiene_id, @target.mx_matrix)
			if last_senke && !last_senke.mx_quelle.nil?
				if next_val == "N+1"
					@target.update_attributes(:mx_quelle => last_senke.mx_quelle+1) 
				else
					@target.update_attributes(:mx_quelle => last_senke.mx_quelle) 
				end
			end
		end

		page.replace_html "target_mx_#{@target.id}", :partial => "kreuzschienes/mx_quelle_select", :locals => {:target => @target, :page => @page}
	  end
	end

  end

  def setChangeAll
    if params[:opt] == "yes"
      session[:SENKEN_CHANGE_ALL] = 1
    else
      session[:SENKEN_CHANGE_ALL] = 0
    end
    
    render :update do |page|
    
    end
  end
  
  def dropdowns
    #render :text => params[:bediengeraets][:kv].blank?.inspect and return false
	@system = System.find(cookies[:system_id])
	@id = params[:id] 
	@typetarget = Typetarget.find(@id)
	@update_matrix = 0

	if @typetarget.matrix.nil? && @typetarget.bediengeraet.bdtype_id == 3
		@typetarget.update_attributes(:matrix => @typetarget.bediengeraet.normalquellen_kv_id)
		@update_matrix = 1
		@kvlink = Kreuzschiene.getMatrix(@typetarget.matrix, @system.id)

		if session[:display].nil? || session[:display]=='name' 
			@kvtitle = @kvlink.name 
		else
			@kvtitle = @kvlink.intnummer
		end
	end


	if !params[:bediengeraets].nil? && !params[:bediengeraets][:kv].nil?
		if !params[:bediengeraets][:kv].blank?
		  @kv = Kreuzschiene.getMatrix(params[:bediengeraets][:kv], @system.id)
		  @kv_val = @kv.id #params[:bediengeraets][:kv]
		  @typetarget.update_attributes(:matrix => @kv.intnummer)
		else
		  @kv = nil
		  @kv_val = nil
		end
	else
		@kv = Kreuzschiene.getMatrix(params[:kv], @system.id)
		@kv_val = @kv.id #params[:kv]
	end

	prev_target = Typetarget.find(@id.to_i-1) if @typetarget.tasten_id !=1
	next_val = Option.getNextOption.value


	if @typetarget.bediengeraet.bdtype_id != 3
		if next_val == "N+1"
			if !prev_target.nil?
				@typetarget.update_attributes(:target_id => prev_target.target_id+1)
			end
		else
			@typetarget.update_attributes(:target_id => prev_target.target_id)
		end
	else
		if @typetarget.tasten_id !=1
			if prev_target.matrix == @typetarget.matrix
				if next_val == "N+1"
					@typetarget.update_attributes(:target_id => prev_target.target_id+1)
				else
					@typetarget.update_attributes(:target_id => prev_target.target_id)
				end
			else
				last_quelle = Typetarget.getLastQuelle(@typetarget.bediengeraet_id, @typetarget.matrix)
				if last_quelle && !last_quelle.target_id.nil?
					if next_val == "N+1"
						@typetarget.update_attributes(:target_id => last_quelle.target_id+1)
					else
						@typetarget.update_attributes(:target_id => last_quelle.target_id)
					end
				end
			end
		end
	end
	#@typetarget.update_attribute(:matrix => matrix)
  end

  def kv_dropdowns
	panel = Typetarget.find(params[:id])
	panel.update_attributes(:matrix => panel.bediengeraet.normalquellen_kv_id) if panel.matrix.nil?

	if session[:display].nil? || session[:display]=='name' then
	  @kv = Kreuzschiene.find(:all, :conditions=>["system_id=? and name!=''", cookies[:system_id]], :order=>"intnummer").map {|u| [u.name, u.intnummer]}
	else
	  @kv = Kreuzschiene.find(:all, :conditions=>["system_id=? and name!=''", cookies[:system_id]], :order=>"intnummer").map {|u| [u.intnummer, u.intnummer]}
	end
  end
 
  def get_matrix_senken
	@target = Target.find(params[:id])
	if session[:display].nil? || session[:display]=='name' then
		@kv = Kreuzschiene.find(:all, :conditions => ["system_id=? and name!=''", cookies[:system_id]], :order => "intnummer").map {|u| [u.name, u.intnummer]}
	else
		@kv = Kreuzschiene.find(:all, :conditions=>["system_id=? and name!=''", cookies[:system_id]], :order=>"intnummer").map {|u| [u.intnummer, u.intnummer]}
	end
	render :update do |page|
		page.replace_html "target_matrix#{@target.id}", :partial => "kreuzschienes/get_matrix_senken"
	end
  end

  def get_mx_matrix_senken
	@target = Target.find(params[:id])
	if session[:display].nil? || session[:display]=='name' then
		@kv = Kreuzschiene.find(:all, :conditions => ["system_id=? and name!=''", cookies[:system_id]], :order => "intnummer").map {|u| [u.name, u.intnummer]}
	else
		@kv = Kreuzschiene.find(:all, :conditions=>["system_id=? and name!=''", cookies[:system_id]], :order=>"intnummer").map {|u| [u.intnummer, u.intnummer]}
	end
	render :update do |page|
		page.replace_html "target_mx_matrix#{@target.id}", :partial => "kreuzschienes/get_mx_matrix_senken"
	end
  end

  def get_channel_senken
	@target = Target.find(params[:id])
	render :update do |page|
		page.replace_html "target_channel_#{@target.id}", :partial => "kreuzschienes/get_channel_senken"
	end
  end

  def get_family_senken
	@target = Target.find(params[:id])
	if @target.intnummer != 1
	  prev_target = Target.find(@target.id-1)
	  @target.update_attribute("family_id",prev_target.family_id)
	end
	if session[:display].nil? || session[:display]=='name' then
		@families = Family.find(:all, :order => "nummer").map {|u| [u.name, u.nummer]}
	else
		@families = Family.find(:all, :order => "nummer").map {|u| [u.nummer, u.nummer]}
	end
	render :update do |page|
		page.replace_html "target_family_#{@target.id}", :partial => "kreuzschienes/get_family_senken"
	end
  end

  def get_mx_quelle
	@target = Target.find(params[:row])
	prev_source = Target.find(@target.id-1)
	next_val = Option.getNextOption.value

	if prev_source.mx_matrix == @target.mx_matrix
		if next_val == "N+1"
			@target.update_attributes(:mx_quelle => prev_source.mx_quelle+1)
		else
			@target.update_attributes(:mx_quelle => prev_source.mx_quelle)
		end
	else
		last_quelle = Target.getLastSenke(@target.kreuzschiene_id, @target.mx_matrix)
		if last_quelle && !last_quelle.mx_quelle.nil?
			if next_val == "N+1"
				@target.update_attributes(:mx_quelle => last_quelle.mx_quelle+1)
			else
				@target.update_attributes(:mx_quelle => last_quelle.mx_quelle)
			end
		end
	end

	render :update do |page|
		page.replace_html "target_mx_#{@target.id}", :partial => "kreuzschienes/mx_quelle_select"
	end
  end

  def get_senke
	@page = "senken"
	@target = Target.find(params[:row])
	prev_source = Target.find(@target.id-1)
	next_val = Option.getNextOption.value

	if prev_source.matrix.to_i == @target.matrix.to_i
		if next_val == "N+1"
			@target.update_attributes(:quelle => prev_source.quelle.to_i+1)
		else
			@target.update_attributes(:quelle => prev_source.quelle)
		end
	else
		last_quelle = Target.getLastQuelle(@target.kreuzschiene_id, @target.matrix)
		if last_quelle && !last_quelle.quelle.nil?
			if next_val == "N+1"
				@target.update_attributes(:quelle => last_quelle.quelle.to_i+1)
			else
				@target.update_attributes(:quelle => last_quelle.quelle)
			end
		end
	end

	render :update do |page|
		page.replace_html "target_#{@target.id}", :partial => "kreuzschienes/quelle_select"
	end
  end

  def get_hlsd
	field = params[:field]
	@page = params[:page]

	@target = Target.find(params[:row])
	next_val = Option.getNextOption.value
	prev_target = Target.find(@target.id-1) if @target.intnummer != 1

	@signals = SignalQuellen.getQuellenSignals.map{|u| [u.title, u.intnummer]} if @page == "quellen"
	@signals = SignalSenken.getSenkenSignals.map{|u| [u.title, u.intnummer]}  if @page == "senken"
	@subclass = getHLSDCollection
	@component = getHLSDCollection
	@subcomponent = getHLSDCollection 

	@target.update_attributes(:signal => prev_target.signal, :subclass => prev_target.subclass, :subcomponent => prev_target.subcomponent) if prev_target

	if prev_target
		if next_val == "N+1" && !prev_target.component.nil?
			@target.update_attributes(:component => "#{prev_target.component+1}") 
		else
			@target.update_attributes(:component => prev_target.component)
		end
	end

	render :update do |page|
		page.replace_html "target_signal#{@target.id}", :partial => "kreuzschienes/hlsd_select", :locals => {:field => "signal"}
		page.replace_html "target_subclass#{@target.id}", :partial => "kreuzschienes/hlsd_select", :locals => {:field => "subclass"}
		page.replace_html "target_component#{@target.id}", :partial => "kreuzschienes/hlsd_select", :locals => {:field => "component"}
		page.replace_html "target_subcomponent#{@target.id}", :partial => "kreuzschienes/hlsd_select", :locals => {:field => "subcomponent"}
	end
  end
end
