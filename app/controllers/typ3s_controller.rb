class Typ3sController < ApplicationController

  def show
	@quellen_font = Global::QUELLEN_FONT
	@senken_font = Global::SENKEN_FONT

	@system = System.find(cookies[:system_id])
	@panel = Bediengeraet.getBediengeraet(params[:id], @system)
	@kv = Kreuzschiene.find(:all, :conditions=>["system_id=? and name!=''", cookies[:system_id]], :select => "id, intnummer, name", :order=>"intnummer")

	if @panel.typesources.size<1 then
	  Typ3.create(@panel.id, cookies[:system_id])
	end

	if session[:display].nil? || session[:display]=='name' then
	  @kv_1 = @kv.map {|u| [u.name, u.intnummer]}
	  @kv_2 = @kv.map {|u| [u.name, u.intnummer]}
	else
	  @kv_1 = @kv.map {|u| [u.intnummer, u.intnummer]}
	  @kv_2 = @kv.map {|u| [u.intnummer, u.intnummer]}
	end

	if !@panel.sende_matrix_id.blank? && !@panel.sende_matrix_id.nil? 
		@panel_kv = Kreuzschiene.getMatrix(@panel.sende_matrix_id, @system)
		#@panel_kv = @kv_panel.id

		@sn = Target.find_all_by_kreuzschiene_id(@panel_kv.id, :order => "nummer", :limit => @panel_kv.input).map {|u| [u.name5stellig, u.intnummer]}
	end

	respond_to do |format|
	  if session[:display].nil? || session[:display]=='name' then
		action ="show_name"
	  else
		action ="show"
	  end
	  format.html { render :action => action, :id => @panel.intnummer }
	end
  end

  # GET /typ3s/new
  # GET /typ3s/new.xml
  def new

    Typ3.create(params[:id], cookies[:system_id])

    respond_to do |format|
        if session[:display].nil? || session[:display]=='name' then
          action ="show_name"
        else
          action ="show"
        end
        format.html { render :action => action, :id=>@panel.intnummer }
    end
  end


  # 1:1 Belegungen der etwaigen Tasten
  def oneonone

	@panel = Bediengeraet.find(params[:id])
	if session[:display].nil? || session[:display]=='name' then
	  @kv = Kreuzschiene.find(:all, :conditions=>["system_id=? and name!=''", cookies[:system_id]], :order=>"intnummer").map {|u| [u.name, u.id]}
	else
	  @kv = Kreuzschiene.find(:all, :conditions=>["system_id=? and name!=''", cookies[:system_id]], :order=>"intnummer").map {|u| [u.id, u.id]}
	end

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
	  if params[:opt].nil?
		  Global::TYP3_NORMALQUELLEN.times  {
			c=c+1
			if c+1 <= kv_matrix.input.to_i
			  d=c
			else
			  d=0
			end
			Typesource.new(:tasten_id => c, :bediengeraet_id => @panel.id, :source_id => d, :sourcetype => 'normal', :matrix => matrix).save
		  }
	  else
		  Global::TYP3_NORMALQUELLEN.times  {
			c=c+1
			Typesource.new(:tasten_id => c, :bediengeraet_id => @panel.id, :source_id => 0, :sourcetype => 'normal', :matrix => nil).save
		  }
	  end
	end

	if params[:part]=="splits" then
	  @panel.splitsources.each do |x| x.destroy end 
	  c=0
	  if params[:opt].nil?
		  Global::TYP3_SPLITQUELLEN.times  {
			c=c+1
			if c+1 <= kv_matrix.input.to_i
			  d=c
			else
			  d=0
			end
			Typesource.new(:tasten_id=>c, :bediengeraet_id=>@panel.id, :source_id=>d, :sourcetype=>'split', :matrix => matrix).save
		  }
	  else
		  Global::TYP3_SPLITQUELLEN.times  {
			c=c+1
			Typesource.new(:tasten_id=>c, :bediengeraet_id=>@panel.id, :source_id=>0, :sourcetype=>'split', :matrix => nil).save
		  }
	  end
	end

	if params[:part]=="senken" then
	  @panel.typetargets.each do |x| x.destroy end
	  c=0
	  d=0
	  if params[:opt].nil?
		  Global::TYP3_SENKEN.times  {
			c=c+1
			d=d+1
			if c+1 <= kv_matrix.output.to_i
			  e=d
			else
			  e=0
			end
			if [16,32,48,64,80].include? c
				c=c+1
			end
			Typetarget.new(:tasten_id=>c, :bediengeraet_id=>@panel.id, :target_id=>e, :matrix => matrix).save
		  }
	  else
		Global::TYP3_SENKEN.times  {
			c=c+1
			if [16,32,48,64,80].include? c
				c=c+1
			end
			Typetarget.new(:tasten_id=>c, :bediengeraet_id=>@panel.id, :target_id=>0, :matrix => nil).save
		  }
	  end
	end
	
	flash[:notice] = '1:1 Belegung durchgef&uuml;hrt'
	
	redirect_to :action=>'show', :id=>@panel.intnummer

  end
  
  
end
