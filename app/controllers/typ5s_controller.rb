class Typ5sController < ApplicationController

  def show
	@quellen_font = Global::QUELLEN_FONT
	@senken_font = Global::SENKEN_FONT
    @system = System.find(cookies[:system_id])
    @panel = Bediengeraet.getBediengeraet(params[:id], @system)
	@panel_function = PanelFunction.find_by_bediengeraet_id(@panel.id)
    @kv = Kreuzschiene.find(:all, :conditions=>["system_id=? and name!=''", cookies[:system_id]], :order=>"intnummer")
    
    if @panel.typesources.size < 1 then
      Typ5.create(@panel.id, cookies[:system_id])
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
        format.html { render :action => action, :id=>@panel }
    end
  end

  # GET /typ5s/new
  # GET /typ5s/new.xml
  def new

    Typ5.create(params[:id], cookies[:system_id])

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
      Global::TYP5_NORMALQUELLEN.times  {
        c=c+1
	if c+1 <= @kv_select.input.to_i
	  d=c
	else
	  d=0
	end
        Typesource.new(:tasten_id=>c, :bediengeraet_id=>@panel.id, :source_id=>d, :sourcetype=>'normal').save
      }
    end
    
    if params[:part]=="splits" then
      @panel.splitsources.each do |x| x.destroy end 
      c=0
      Global::TYP5_SPLITQUELLEN.times  {
        c=c+1
	if c+1 <= @kv_select.input.to_i
	  d=c
	else
	  d=0
	end
        Typesource.new(:tasten_id=>c, :bediengeraet_id=>@panel.id, :source_id=>d, :sourcetype=>'split').save
      }
    end

    if params[:part]=="senken" then
      @panel.typetargets.each do |x| x.destroy end
      c=0
      d=0
      Global::TYP5_SENKEN.times  {
        c=c+1
        d=d+1
		if c+1 <= @kv_select.output.to_i
		  e=d
		else
		  e=0
		end

		if !@panel_function.nil?
			if @panel_function.family.to_i == 1 && @panel_function.audis.to_i == 1				
				if Global::AUDIS_FAMILY_SHIFT_ARRAY_PANEL5.include?(c)
					c+=3
				end
			elsif @panel_function.family.to_i == 1
				if Global::FAMILY_SHIFT_ARRAY_PANEL5.include?(c)
					c+=2
				end
			elsif @panel_function.audis.to_i == 1				 
				if Global::AUDIS_ARRAY_PANEL5.include?(c)
					c+=1
				elsif Global::SHIFT_ARRAY_PANEL5.include?(c)
					c+=1
				end	
			end
			Typetarget.new(:tasten_id=>c, :bediengeraet_id=>@panel.id, :target_id=>e).save
		else
		    if Global::SHIFT_ARRAY_PANEL5.include?(c)
		        c=c+1
		    end
		    Typetarget.new(:tasten_id=>c, :bediengeraet_id=>@panel.id, :target_id=>e).save
		end
      }
    end

    flash[:notice] = '1:1 Belegung durchgef&uuml;hrt'

    redirect_to :action=>'show', :id=>@panel.intnummer

  end

  def update_function_keys
	system_id = cookies[:system_id]
	@panel = Bediengeraet.find_by_system_id_and_id(system_id, params[:id])
	@panel_function = PanelFunction.find_by_bediengeraet_id(@panel.id)
	@panel_senken = Typetarget.find_all_by_bediengeraet_id(params[:id], 'normal')	
	render :update do |page|
		if @panel_function.nil?
			@function = PanelFunction.new()
			@function.bediengeraet_id = @panel.id
			@function.family = params[:family].nil? ? "0" : params[:family]
			@function.audis = params[:audis].nil? ? "0" : params[:audis]
			@function.save
			c=1
			if @function.family == 1 && @function.audis == 1
				Typetarget.delete_all("bediengeraet_id = #{@panel.id}")
				@panel_senken.each do |ts|	
					if Global::AUDIS_FAMILY_SHIFT_ARRAY_PANEL5.include?(c)
						c+=3				
					end					
					Typetarget.new(:tasten_id=>c, :bediengeraet_id=>@panel.id, :target_id =>ts.target_id).save
				c+=1
				end
			elsif @function.family == 1
				Typetarget.delete_all("bediengeraet_id = #{@panel.id}")
				@panel_senken.each do |ts|	
					if Global::FAMILY_SHIFT_ARRAY_PANEL5.include?(c)
						c+=2
					end					
					Typetarget.new(:tasten_id=>c, :bediengeraet_id=>@panel.id, :target_id=>ts.target_id).save
				c+=1
				end
			elsif @function.audis == 1
				Typetarget.delete_all("bediengeraet_id = #{@panel.id}")
				@panel_senken.each do |ts|	
					if Global::AUDIS_ARRAY_PANEL5.include?(c)
						c+=1
					elsif Global::SHIFT_ARRAY_PANEL5.include?(c)
						c+=1
					end	
					Typetarget.new(:tasten_id=>c, :bediengeraet_id=>@panel.id, :target_id=>ts.target_id).save									
				c+=1
				end
			else
				Typetarget.delete_all("bediengeraet_id = #{@panel.id}")
				@panel_senken.each do |ts|	
					if Global::SHIFT_ARRAY_PANEL5.include?(c)
						c+=1
					end	
					Typetarget.new(:tasten_id=>c, :bediengeraet_id=>@panel.id, :target_id=>ts.target_id).save									
				c+=1
				end
			end
		else		
			@panel_function.family = params[:family].nil? ? "0" : params[:family]
			@panel_function.audis = params[:audis].nil? ? "0" : params[:audis]
			@panel_function.save
			c=1
			if @panel_function.family.to_i == 1 && @panel_function.audis.to_i == 1				
				Typetarget.delete_all("bediengeraet_id = #{@panel.id}")
				@panel_senken.each do |ts|	
					if Global::AUDIS_FAMILY_SHIFT_ARRAY_PANEL5.include? (c)
						c+=3				
					end					
					Typetarget.new(:tasten_id=>c, :bediengeraet_id=>@panel.id, :target_id=>ts.target_id).save
				c+=1
				end
			elsif @panel_function.family == 1
				Typetarget.delete_all("bediengeraet_id = #{@panel.id}")
				@panel_senken.each do |ts|	
					if Global::FAMILY_SHIFT_ARRAY_PANEL5.include? (c)
						c+=2
					end					
					Typetarget.new(:tasten_id=>c, :bediengeraet_id=>@panel.id, :target_id=>ts.target_id).save
				c+=1
				end
			elsif @panel_function.audis == 1
				Typetarget.delete_all("bediengeraet_id = #{@panel.id}")
				@panel_senken.each do |ts|	
					if Global::AUDIS_ARRAY_PANEL5.include? (c)
						c+=1
					elsif Global::SHIFT_ARRAY_PANEL5.include? c
						c+=1
					end	
					Typetarget.new(:tasten_id=>c, :bediengeraet_id=>@panel.id, :target_id=>ts.target_id).save									
				c+=1
				end
			else
				Typetarget.delete_all("bediengeraet_id = #{@panel.id}")
				@panel_senken.each do |ts|	
					if Global::SHIFT_ARRAY_PANEL5.include? (c)
						c+=1
					end	
					Typetarget.new(:tasten_id=>c, :bediengeraet_id=>@panel.id, :target_id=>ts.target_id).save									
				c+=1
				end
			end
		end
	page.redirect_to "/typ5s/show/#{@panel.intnummer}"
	end
  end

end
