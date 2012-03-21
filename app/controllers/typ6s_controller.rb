class Typ6sController < ApplicationController

  
  # GET /Typ6s/1
  # GET /Typ6s/1.xml
  def show
	@quellen_font = Global::QUELLEN_FONT
	@senken_font = Global::SENKEN_FONT

   @system = System.find(cookies[:system_id])
   @panel = Bediengeraet.getBediengeraet(params[:id], @system)
   @panel_function = PanelFunction.find_by_bediengeraet_id(@panel.id)
   @kv = Kreuzschiene.find(:all, :conditions=>["system_id=? and name!=''", cookies[:system_id]], :order=>"intnummer")
   @button_per_row = Global::BUTTON_PER_ROW_PANEL6
   if @panel.typesources.size < 1 then
      Typ6.create(@panel.id, @system.id)
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

  # GET /Typ6s/new
  # GET /Typ6s/new.xml
  def new
    
    Typ6.create(params[:id], cookies[:system_id])
         
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
	@panel_function = PanelFunction.find_by_bediengeraet_id(@panel.id)
    if session[:display].nil? || session[:display]=='name' then
      @kv = Kreuzschiene.find(:all, :conditions=>["system_id=? and name!=''", cookies[:system_id]], :order=>"intnummer").map {|u| [u.name, u.id]}
    else
      @kv = Kreuzschiene.find(:all, :conditions=>["system_id=? and name!=''", cookies[:system_id]], :order=>"intnummer").map {|u| [u.id, u.id]}
    end

    @kv_select = Kreuzschiene.find_by_intnummer_and_system_id(@panel.normalquellen_kv_id, cookies[:system_id])		
    if @panel.normalquellen_kv_id.nil? then
      flash[:notice] = '<font color="red">Es wurde keine Kreuzschiene ausgew&auml;hlt</font>'
      redirect_to :action => 'show', :id => @panel.intnummer
      return
    end
    # Quellen anlegen
    if params[:part]=="quellen" then
      @panel.normalsources.each do |x| x.destroy end 
      c=0
      d=0
      Global::TYP6_NORMALQUELLEN.times  {
        c=c+1
        d=d+1
		if c+1 <= @kv_select.input.to_i
		  e=d
		else
		  e=0
		end
		if !@panel_function.nil?
			if @panel_function.family.to_i == 1 && @panel_function.audis.to_i == 1				
				if Global::AUDIS_FAMILY_SHIFT_ARRAY_PANEL6.include?(c)
					c+=3
				end
			elsif @panel_function.family.to_i == 1
				if Global::FAMILY_SHIFT_ARRAY_PANEL6.include?(c)
					c+=2
				end
			elsif @panel_function.audis.to_i == 1				 
				if Global::AUDIS_ARRAY_PANEL6.include?(c)
					c+=1
				elsif Global::SHIFT_ARRAY_PANEL6.include?(c)
					c+=1
				end	
			end
			Typesource.new(:tasten_id=>c, :bediengeraet_id=>@panel.id, :source_id=>e, :sourcetype=>'normal').save
		else
		    if Global::SHIFT_ARRAY_PANEL6.include?(c)
		        c=c+1
		    end
		    Typesource.new(:tasten_id=>c, :bediengeraet_id=>@panel.id, :source_id=>e, :sourcetype=>'normal').save
		end
      }
    end

    if params[:part]=="senken" then
      @panel.typetargets.each do |x| x.destroy end
      Typetarget.new(:tasten_id=>1, :bediengeraet_id=>@panel.id, :target_id=>1).save
    end

    flash[:notice] = '1:1 Belegung durchgef&uuml;hrt'

    redirect_to :action=>'show', :id=>@panel.intnummer

  end

  def update_function_keys
	system_id = cookies[:system_id]
	@panel = Bediengeraet.find_by_system_id_and_id(system_id, params[:id])
	@panel_function = PanelFunction.find_by_bediengeraet_id(@panel.id)
	@panel_quellen = Typesource.find_all_by_bediengeraet_id_and_sourcetype(params[:id], 'normal')	
	render :update do |page|
		if @panel_function.nil?
			@function = PanelFunction.new()
			@function.bediengeraet_id = @panel.id
			@function.family = params[:family].nil? ? "0" : params[:family]
			@function.audis = params[:audis].nil? ? "0" : params[:audis]
			@function.save
			c=1
			if @function.family == 1 && @function.audis == 1
				Typesource.delete_all("bediengeraet_id = #{@panel.id}")
				@panel_quellen.each do |ts|	
					if Global::AUDIS_FAMILY_SHIFT_ARRAY_PANEL6.include?(c)
						c+=3				
					end					
					Typesource.new(:tasten_id=>c, :bediengeraet_id=>@panel.id, :source_id=>ts.source_id, :sourcetype=>'normal').save
				c+=1
				end
			elsif @function.family == 1
				Typesource.delete_all("bediengeraet_id = #{@panel.id}")
				@panel_quellen.each do |ts|	
					if Global::FAMILY_SHIFT_ARRAY_PANEL6.include?(c)
						c+=2
					end					
					Typesource.new(:tasten_id=>c, :bediengeraet_id=>@panel.id, :source_id=>ts.source_id, :sourcetype=>'normal').save
				c+=1
				end
			elsif @function.audis == 1
				Typesource.delete_all("bediengeraet_id = #{@panel.id}")
				@panel_quellen.each do |ts|	
					if Global::AUDIS_ARRAY_PANEL6.include?(c)
						c+=1
					elsif Global::SHIFT_ARRAY_PANEL6.include?(c)
						c+=1
					end	
					Typesource.new(:tasten_id=>c, :bediengeraet_id=>@panel.id, :source_id=>ts.source_id, :sourcetype=>'normal').save									
				c+=1
				end
			else
				Typesource.delete_all("bediengeraet_id = #{@panel.id}")
				@panel_quellen.each do |ts|	
					if Global::SHIFT_ARRAY_PANEL6.include?(c)
						c+=1
					end	
					Typesource.new(:tasten_id=>c, :bediengeraet_id=>@panel.id, :source_id=>ts.source_id, :sourcetype=>'normal').save									
				c+=1
				end
			end
		else		
			@panel_function.family = params[:family].nil? ? "0" : params[:family]
			@panel_function.audis = params[:audis].nil? ? "0" : params[:audis]
			@panel_function.save
			c=1
			if @panel_function.family.to_i == 1 && @panel_function.audis.to_i == 1				
				Typesource.delete_all("bediengeraet_id = #{@panel.id}")
				@panel_quellen.each do |ts|	
					if Global::AUDIS_FAMILY_SHIFT_ARRAY_PANEL6.include? (c)
						c+=3				
					end					
					Typesource.new(:tasten_id=>c, :bediengeraet_id=>@panel.id, :source_id=>ts.source_id, :sourcetype=>'normal').save
				c+=1
				end
			elsif @panel_function.family == 1
				Typesource.delete_all("bediengeraet_id = #{@panel.id}")
				@panel_quellen.each do |ts|	
					if Global::FAMILY_SHIFT_ARRAY_PANEL6.include? (c)
						c+=2
					end					
					Typesource.new(:tasten_id=>c, :bediengeraet_id=>@panel.id, :source_id=>ts.source_id, :sourcetype=>'normal').save
				c+=1
				end
			elsif @panel_function.audis == 1
				Typesource.delete_all("bediengeraet_id = #{@panel.id}")
				@panel_quellen.each do |ts|	
					if Global::AUDIS_ARRAY_PANEL6.include? (c)
						c+=1
					elsif Global::SHIFT_ARRAY_PANEL6.include? c
						c+=1
					end	
					Typesource.new(:tasten_id=>c, :bediengeraet_id=>@panel.id, :source_id=>ts.source_id, :sourcetype=>'normal').save									
				c+=1
				end
			else
				Typesource.delete_all("bediengeraet_id = #{@panel.id}")
				@panel_quellen.each do |ts|	
					if Global::SHIFT_ARRAY_PANEL6.include? (c)
						c+=1
					end	
					Typesource.new(:tasten_id=>c, :bediengeraet_id=>@panel.id, :source_id=>ts.source_id, :sourcetype=>'normal').save									
				c+=1
				end
			end
		end
	page.redirect_to "/typ6s/show/#{@panel.intnummer}"
	end
  end

end
