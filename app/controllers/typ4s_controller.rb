class Typ4sController < ApplicationController

  def show
	@quellen_font = Global::QUELLEN_FONT
	@senken_font = Global::SENKEN_FONT

    @system = System.find(cookies[:system_id])
    @panel = Bediengeraet.getBediengeraet(params[:id], @system)
    @kv = Kreuzschiene.find(:all, :conditions=>["system_id=? and name!=''", cookies[:system_id]], :order=>"intnummer")
    
    if @panel.typesources.size<1 then
      Typ4.create(@panel.id, cookies[:system_id])
    end

    if session[:display].nil? || session[:display]=='name' then
      @kv_1 = @kv.map {|u| [u.name, u.intnummer]}
    else
      @kv_1 = @kv.map {|u| [u.intnummer, u.intnummer]}
    end
    respond_to do |format|
        if session[:display].nil? || session[:display]=='name' then
          action ="show_name"
        else
          action ="show"
        end
        format.html { render :action => action, :id=>@panel.intnummer }
    end
  end

  # GET /typ3s/new
  # GET /typ3s/new.xml
  def new
    
    Typ4.create(params[:id], cookies[:system_id])
     
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
  
    @kv_select = Kreuzschiene.find_by_intnummer_and_system_id(@panel.normalquellen_kv_id, cookies[:system_id])
    if @panel.normalquellen_kv_id.nil? then
      flash[:notice] = '<font color="red">Es wurde keine Kreuzschiene ausgew&auml;hlt</font>'
      redirect_to :action=>'show', :id=>@panel.intnummer
      return
    end

    
    # Quellen anlegen
    if params[:part]=="quellen" then
      @panel.normalsources.each do |x| x.destroy end 
      c=0
      Global::TYP4_NORMALQUELLEN.times  {
        c=c+1
	if c+1 <= @kv_select.input.to_i
	  d=c
	else
	  d=0
	end
        Typesource.new(:tasten_id=>c, :bediengeraet_id=>@panel.id, :source_id=>d, :sourcetype=>'normal').save
      }
    end
    
    if params[:part]=="senken" then
      @panel.typetargets.each do |x| x.destroy end
      Typetarget.new(:tasten_id=>1, :bediengeraet_id=>@panel.id, :target_id=>1).save
    end  

    flash[:notice] = '1:1 Belegung durchgef&uuml;hrt'
    
    redirect_to :action=>'show', :id=>@panel.intnummer
    
  end
  
end
