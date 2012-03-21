class CrosspointsController < ApplicationController

  layout "application", :except=>['show_single_edit', 'show_single_ajax']
  # GET /crosspoints/1
  # GET /crosspoints/1.xml
  def getKvList
		if session[:display].nil? || session[:display]=='name' then
			@kv = Kreuzschiene.find(:all, :conditions=>["system_id=? and name!=''", cookies[:system_id]], :order=>"intnummer").map {|u| [u.name, u.id]}
		else
			@kv = Kreuzschiene.find(:all, :conditions=>["system_id=? and name!=''", cookies[:system_id]], :order=>"intnummer").map {|u| [u.intnummer, u.id]}
		end
  end

  def salvo_template_setup
	  @system = System.find(cookies[:system_id])
	  @salvo = Salvo.getSalvo(@system.id, params[:id])
	  @setups = Crosspoint.get_salvo_setups(@system.id, @salvo.intnummer)
	  getKvList
    # @kv

	  case @salvo.salvo_type
	    when 0
	      render :action => "salvo_template_setup"
	    when 1
	      render :action => "salvo_template_setup_lynx"
	    when 2
	      render :action => "salvo_template_setup_lavo"
    end
#    render :text => @salvo.salvo_type.inspect and return false
  end

  def show_single_edit

	  system_id = cookies[:system_id]
	  display = params[:display]
	  @crosspoint = Crosspoint.find(params[:id])

	  update_crosspoint

	  if display.nil? || display=='name' then
	    @quellen = Source.find(:all, :conditions=>["name4stellig!='' and kreuzschiene_id=?", @crosspoint.kreuzschiene.id]).map {|u| [u.name5stellig, u.id]}
	    @senken = Target.find(:all, :conditions=>["name4stellig!='' and kreuzschiene_id=?", @crosspoint.kreuzschiene.id]).map {|u| [u.name5stellig, u.id]}
	    @kv = Kreuzschiene.find(:all, :conditions=>["system_id=? and name!=''", system_id], :order=>"intnummer").map {|u| [u.name, u.id]}
	    @kreuzschiene_name = @crosspoint.kreuzschiene.name
	  else
	    @quellen = Source.find(:all, :conditions=>["name4stellig!='' and kreuzschiene_id=?", @crosspoint.kreuzschiene.id]).map {|u| [u.intnummer, u.id]}
	    @senken = Target.find(:all, :conditions=>["name4stellig!='' and kreuzschiene_id=?", @crosspoint.kreuzschiene.id]).map {|u| [u.intnummer, u.id]}
	    @kv = Kreuzschiene.find(:all, :conditions=>["system_id=? and name!=''", system_id], :order=>"intnummer").map {|u| [u.intnummer, u.id]}
	    @kreuzschiene_name = @crosspoint.kreuzschiene.intnummer
	  end
  end

  def show_single_ajax
		system_id = cookies[:system_id]
		@currcrosspoint = Crosspoint.find(params[:id])
		if session[:display].nil? || session[:display]=='name' then
			@quellen = Source.find(:all, :conditions=>["name4stellig!='' and kreuzschiene_id=?", @currcrosspoint.kreuzschiene.id]).map {|u| [u.name5stellig, u.id]}
			@senken = Target.find(:all, :conditions=>["name4stellig!='' and kreuzschiene_id=?", @currcrosspoint.kreuzschiene.id]).map {|u| [u.name5stellig, u.id]}
			@kv = Kreuzschiene.find(:all, :conditions=>["system_id=?", system_id]).map {|u| [u.name, u.id]}
		else
			@quellen = Source.find(:all, :conditions=>["name4stellig!=''"]).map {|u| [u.id, u.id]}
			@senken = Target.find(:all, :conditions=>["name4stellig!=''"]).map {|u| [u.id, u.id]}
			@kv = Kreuzschiene.find(:all, :conditions=>["system_id=?", system_id]).map {|u| [u.id , u.id]}
		end
  end

  def update_kv
		@crosspoint = Crosspoint.find(params[:id])
		@crosspoint.update_attributes(params[:crosspoint])
		@system = System.find(cookies[:system_id])

		@setups = Crosspoint.get_salvo_setups(@system.id, @crosspoint.salvo_id)
		getKvList

		@salvo_type = Salvo.find_by_system_id_and_intnummer(@system.id, @crosspoint.salvo_id)
		if @salvo_type.salvo_type==0
			update_crosspoint
		end

		render :update do |page|
			if @salvo_type.salvo_type.to_i==0
				page.replace_html "crosspoint_container", :partial => "crosspoint_list"
				page.hide "spin_#{params[:id]}"
			elsif @salvo_type.salvo_type.to_i==1
	#			page.replace_html "crosspoint_container", :partial => "crosspoint_list_lynx"
				page.replace_html "div_#{params[:id]}",:partial => "lynx_fields",:locals => {:f => @crosspoint}
				page.hide "spin_#{params[:id]}"
			elsif @salvo_type.salvo_type.to_i==2
				page.replace_html "crosspoint_container", :partial => "crosspoint_list_lavo"
				page.hide "spin_#{params[:id]}"
			end
		end
  end

  def update
		@crosspoint = Crosspoint.find(params[:id])
		@crosspoint.update_attributes(params[:crosspoint])

		respond_to do |format|
			format.html { redirect_to :action => "show_single_ajax", :id => @crosspoint.id }
		end
  end

  def update_crosspoint
		next_val = Option.getNextOption.value
		if @crosspoint.nummer!=1
			prev_crosspoint = Crosspoint.find(@crosspoint.id-1)

			if prev_crosspoint.kreuzschiene_id == @crosspoint.kreuzschiene_id
				if next_val == "N+1"
					@crosspoint.update_attributes(:source_id => prev_crosspoint.source_id+1, :target_id => prev_crosspoint.target_id+1)
				else
					@crosspoint.update_attributes(:source_id => prev_crosspoint.source_id, :target_id => prev_crosspoint.target_id)
				end
			else
				last_crosspoint = Crosspoint.getLastkv(@crosspoint.kreuzschiene_id ,@crosspoint.system_id, @crosspoint.id)
				if last_crosspoint && !last_crosspoint.source_id.nil? && !last_crosspoint.target_id.nil?
					if next_val == "N+1"
						@crosspoint.update_attributes(:source_id => last_crosspoint.source_id+1, :target_id => last_crosspoint.target_id+1)
					else
						@crosspoint.update_attributes(:source_id => last_crosspoint.source_id, :target_id => last_crosspoint.target_id)
					end
				end
			end
		end
  end

  def salvo_templates
		@system_id = cookies[:system_id]
		@salvos = Salvo.find_all_by_system_id(@system_id)
  end

  def create_salvo_template
		salvo = Salvo.new(params[:new_salvo])
		salvo.save
		@system = System.find(cookies[:system_id])

		c=1
		128.times {
			Crosspoint.new(:nummer=>c, :salvo_id => salvo.intnummer, :kreuzschiene_id=>nil, :target_id=>nil, :source_id=>nil, :system_id=>@system.id).save
			c=c+1
		}
		redirect_to :back
  end
=begin
	def update_salvo_template
		@system = cookies[:system_id]
		salvo = Salvo.getSalvo(@system, params[:salvo][:intnummer])
		salvo.update_attributes(:name => params[:salvo][:name])
		redirect_to :back
	end
=end

	def update_salvo_template
		@system = System.find(cookies[:system_id])
		salvo = Salvo.getSalvo(@system.id, params[:salvo][:intnummer])
		salvo.update_attributes(:name => params[:salvo][:name], :salvo_type => params[:salvo_type].to_i)
		redirect_to :back
	end

	def delete_salvo_template
		@system = System.find(cookies[:system_id])
		salvo = Salvo.getSalvo(@system.id, params[:id])
		Crosspoint.destroy_all(:system_id => @system.id, :salvo_id => salvo.intnummer)
		salvo.destroy
		redirect_to :action => :salvo_templates
	end

	def change_fields
	  @setup = Crosspoint.find(params[:f_id])
    @kv = Kreuzschiene.find(:all,:joins => "left join matrix_types on kreuzschienes.mixer_template_id = matrix_types.id", :conditions=>["system_id=? and  matrix_types.title = ? ", cookies[:system_id],"Lawo MONPL" ], :order=>"intnummer").map {|u| [u.name, u.id]}
		@signal_quellen = SignalQuellen.find(:all)
    render :update do |page|
      page.replace_html "row_#{params[:f_id]}", :partial => "lawo_fields", :locals => {:f => @setup,:kv => @kv, :signal_quellen => @signal_quellen}
    end
	end

	def update_crosspoint
	  cr = Crosspoint.find(params[:id])
	  cr.update_attributes(params[:crosspoint])
	end

end

