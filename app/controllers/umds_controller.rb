class UmdsController < ApplicationController

  layout "application", :except=>['show_single_edit_kv','show_single_edit_senke','update', 'update_pgm_monitor','show_5stelling']

  def show
    @system = System.find(cookies[:system_id])
    @umds = Umd.find_all_by_system_id(cookies[:system_id])
    @kv = Kreuzschiene.find(:all, :conditions=>["system_id=? and name!=''", cookies[:system_id]]).map {|u| [u.name, u.id]}

    respond_to do |format|
      format.html # index.html.erb
    end
  end


  def update

    @umd = Umd.find(params[:id])
    if !params[:umd][:ip_address].nil? && !params[:umd][:ip_address].blank?
	    params[:umd][:ip_address] = getIpFormat(params[:umd][:ip_address])
    end
    update_sn = 0
    if !params[:umd][:kreuzschiene_id].nil? && params[:umd][:kreuzschiene_id] != @umd.kreuzschiene_id
        update_sn = 1
    end

    @umd.update_attributes(params[:umd])
    val1 = @umd.target_id
    val2 = params[:umd][:target_id]

    if update_sn == 1
        # get_senke
        if session[:display].nil? || session[:display]=='name' then
          if @umd.choice.to_s == '0'#'Senke'
         		@targets = Target.find(:all, :conditions=>["kreuzschiene_id=?", @umd.kreuzschiene_id], :order=>"intnummer").map {|u| [u.name5stellig, u.intnummer]}
          else
            @targets = Source.find(:all, :conditions=>["kreuzschiene_id=?", @umd.kreuzschiene_id], :order=>"intnummer").map {|u| [u.name5stellig, u.intnummer]}
          end
        else
          if @umd.choice.to_s == '0'#'Senke'
            @targets = Target.find(:all, :conditions=>["kreuzschiene_id=?", @umd.kreuzschiene_id], :order=>"intnummer").map {|u| [u.intnummer, u.intnummer]}
          else
            @targets = Source.find(:all, :conditions=>["kreuzschiene_id=?", @umd.kreuzschiene_id], :order=>"intnummer").map {|u| [u.intnummer, u.intnummer]}
          end
        end

        render :update do |page|
            page.replace_html "sn_select_#{@umd.id}", :partial => "update_senke", :locals => {:umd => @umd}
            if @umd.panel.to_i != 1
              page.replace_html "ip_address_#{@umd.id}", collection_select('umd','master_umd',Umd.find(:all,:select =>"intnummer,umdnummer", :conditions => ['system_id = ? ', cookies[:system_id]]),'intnummer','umdnummer', {:selected => @umd.master_umd },{ :onchange=>"document.getElementById('s_l_" + @umd.id.to_s + "').click();"} )
            else
              page.replace_html "ip_address_#{@umd.id}", "#{ text_field 'umd', :ip_address, {:style=>'width:110px;', :onchange=>"document.getElementById('s_l_" + @umd.id.to_s + "').click();"}  }"
            end
        end

    else
      render :update do |page|
            if @umd.panel.to_i != 1

              page.replace_html "ip_address_#{@umd.id}",collection_select('umd','master_umd',Umd.find(:all,:select =>"intnummer,umdnummer", :conditions => ['system_id = ? ', cookies[:system_id]]),'intnummer','umdnummer', {:selected => @umd.master_umd },{ :onchange=>"document.getElementById('s_l_" + @umd.id.to_s + "').click();"} )
            else
              page.replace_html "ip_address_#{@umd.id}", "#{ text_field 'umd', :ip_address, {:value => @umd.ip_address,:style=>'width:110px;', :onchange=>"document.getElementById('s_l_" + @umd.id.to_s + "').click();"}  }"
            end
        end
    end

  end

  def update_pgm_monitor
      @umd = Umd.find(params[:id])
      @umd.update_attributes(:pgm_monitor => params[:val])

      render :update do |page|

      end
  end

  def show_single_edit_kv

    @umd = Umd.find(params[:id])

      if session[:display].nil? || session[:display]=='name' then
        @kv = Kreuzschiene.find(:all, :conditions=>["system_id=? and nummer!='' and name!=''", cookies[:system_id]], :order=>'intnummer').map {|u| [u.name, u.id]}
        @targets = Target.find(:all, :conditions=>["kreuzschiene_id=?", @umd.kreuzschiene_id], :order=>"intnummer").map {|u| [u.name5stellig, u.intnummer]}
      else
        @kv = Kreuzschiene.find(:all, :conditions=>["system_id=? and nummer!='' and name!=''", cookies[:system_id]], :order=>'intnummer').map {|u| [u.intnummer, u.id]}
        @targets = Target.find(:all, :conditions=>["kreuzschiene_id=?", @umd.kreuzschiene_id], :order=>"intnummer").map {|u| [u.intnummer, u.intnummer]}
      end
      get_senke
  end


  def show_single_edit_senke
	@umd = Umd.find(params[:id])

	get_senke
	if session[:display].nil? || session[:display]=='name' then
		@kv = Kreuzschiene.find(:all, :conditions=>["system_id=? and nummer!='' and name!=''", cookies[:system_id]], :order=>'intnummer').map {|u| [u.name, u.id]}
		if params[:choice]=='1'
			@targets = Source.find(:all, :conditions=>["kreuzschiene_id=?", @umd.kreuzschiene_id], :order=>"intnummer").map {|u| [u.name5stellig, u.intnummer]}
		else
			@sources = Target.find(:all, :conditions=>["kreuzschiene_id=?", @umd.kreuzschiene_id], :order=>"intnummer").map {|u| [u.name5stellig, u.intnummer]}
		end
	else
		@kv = Kreuzschiene.find(:all, :conditions=>["system_id=? and nummer!='' and name!=''", cookies[:system_id]], :order=>'intnummer').map {|u| [u.intnummer, u.id]}
		if params[:choice]=='1'
			@targets = Source.find(:all, :conditions=>["kreuzschiene_id=?", @umd.kreuzschiene_id], :order=>"intnummer").map {|u| [u.intnummer, u.intnummer]}
		else
			@sources = Target.find(:all, :conditions=>["kreuzschiene_id=?", @umd.kreuzschiene_id], :order=>"intnummer").map {|u| [u.intnummer, u.intnummer]}
		end
	end

  end

  def get_senke
  next_val = Option.getNextOption.value
	@system = System.find(cookies[:system_id])

	if @umd.intnummer != 1
		prev_umd = Umd.find(@umd.id-1)
	end

    if prev_umd && prev_umd.kreuzschiene_id == @umd.kreuzschiene_id
        if next_val == "N+1"
            @umd.update_attributes(:target_id => prev_umd.target_id+1)
        else
            @umd.update_attributes(:target_id => prev_umd.target_id)
        end
    else
        last_umd = Umd.getLastSenke(@umd.kreuzschiene_id, @system.id)
        if last_umd && !last_umd.target_id.nil?
            if next_val == "N+1"
                @umd.update_attributes(:target_id => last_umd.target_id+1)
            else
                @umd.update_attributes(:target_id => last_umd.target_id)
            end
        end
    end

  end
  def show_5stelling
         @umd=Umd.find(params[:id])
          @umd_update = Umd.find(:all, :conditions => ["intnummer < ? AND choice = ? AND system_id=?", @umd.intnummer, @umd.choice, cookies[:system_id]]).last
          @umd.update_attributes(:target_id=>@umd_update.target_id+1)
	  @quelle = Source.find_all_by_kreuzschiene_id(params[:kid])
  end

end

