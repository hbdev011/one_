class SourcesController < ApplicationController

  layout "application", :except=>['dropdowns', 'kv_dropdowns', 'update']

  def update
      @system = System.find(cookies[:system_id])
      @source = Source.find(params[:id])
      @families = Family.find(:all)
      kv_id = params[:kr_id]
      update_quelle = 0
      update_mx_senke = 0
      update_clone_input = 0 
      make_row_editable = false
    
      if !params[:source][:mx_matrix].nil? && !params[:source][:mx_matrix].blank? && @source.mx_matrix != params[:source][:mx_matrix].to_i
	    update_mx_senke = 1
      end

      if !params[:source][:matrix].nil? && !params[:source][:matrix].blank? && @source.matrix != params[:source][:matrix]
		update_quelle = 1
      end

	#if !params[:source][:par_matrix].nil? && !params[:source][:par_matrix].blank? && @source.par_matrix != params[:source][:par_matrix].to_i
      if (!params[:source][:par_matrix].nil? && !params[:source][:par_matrix].blank?) || (!@source.par_quelle.blank? && !@source.par_quelle.nil?) || (!@source.par_matrix.blank? && !@source.par_matrix.nil?)
	 update_par_matrix = 1
      end

   	render :update do |page|
	   	if session[:QUELLEN_CHANGE_ALL] == 1

	   		if @source.name4stellig != params[:source][:name4stellig]
	   			params[:source][:name5stellig] = params[:source][:name4stellig]
	   			params[:source][:char6] = params[:source][:name4stellig]
	   			params[:source][:char10] = params[:source][:name4stellig]
	   			params[:source][:comment] = params[:source][:name4stellig]
   
	   			update_quelle = 1
	   			id = params[:id]
	   			kr_id = params[:kr_id]
	   			char6 = params[:source][:char6]
   
	   		elsif @source.name5stellig != params[:source][:name5stellig]
      		params[:source][:char6] = params[:source][:name5stellig]
	   			params[:source][:char10] = params[:source][:name5stellig]
	   			params[:source][:comment] = params[:source][:name5stellig]
   
	   			update_quelle = 1
	   			id = params[:id]
      			kr_id = params[:kr_id]
	   			char6 = params[:source][:char6]

	   		elsif @source.char6 != params[:source][:char6]
	   			params[:source][:char10] = params[:source][:char6]
	   			params[:source][:comment] = params[:source][:char6]
      
	   			update_quelle = 1
	   			id = params[:id]
	   			kr_id = params[:kr_id]
	   			char6 = params[:source][:char6]
   
	   		elsif @source.char10 != params[:source][:char10]
	   			params[:source][:comment] = params[:source][:char10]
   
	   		end
			  if params[:source][:enable].nil?
				  params[:source][:enable] = 0
			  end
	   		@source.update_attributes(params[:source])


	   		kr_id = params[:kr_id]
	   		@kreuzschiene = Kreuzschiene.find(kr_id)
	   		@kr_all = Kreuzschiene.find_all_by_system_id(@system.id, :select => "id")
	   		@kr_ids = []
	      		@kr_all.each do |k|
      				@kr_ids << k.id
	   		end
	   		@kr_ids = @kr_ids.join(",")
      
	   		@sources = Source.find_all_by_par_matrix_and_par_quelle(@kreuzschiene.intnummer, @source.intnummer, :conditions => ["kreuzschiene_id in (#{@kr_ids})"])
	   		
	   		@sources.each do |s|
		   		s.update_attributes(params[:source])
	   		end
      
	   		

			page["#{params[:id]}"]["source_name5stellig"]['value'] = @source.name5stellig
			page["#{params[:id]}"]["source_char6"]['value'] = @source.char6
			page["#{params[:id]}"]["source_char10"]['value'] = @source.char10
			page["#{params[:id]}"]["source_comment"]['value'] = @source.comment
   
	   		if update_quelle == 1
				kr_id = params[:kr_id]
				@cloneinputs = Source.find_all_by_cloneinput(id)
				@cloneinputs.each do |c|
					@html = "<center><a style='text-decoration: none;' onclick='new Ajax.Request(\"/sources/updateCloneInput\", {asynchronous:true, evalscripts:true, method:\"post\",parameters: {id: #{kr_id}, source_id: #{c.id}}});' href='Javascript:void(0)'> #{char6} </a></center>"
					page.replace_html "cloneinput_#{c.id}", @html
				end


				@quelle = Source.find_all_by_matrix_and_kreuzschiene_id(@kreuzschiene.name, kr_id)
				@quelle_list = @kreuzschiene.getSourceQuelle
 
				@quelle.each do |c|
					@html = "<select class='ibtTableSelectBox' id='source_quelle' name='source[quelle]' onchange='document.getElementById(\"submitchangeitem#{c.id}\").click();' >
					<option value='' >&nbsp;</option> "
					@quelle_list.each do |q|
						@html += "<option value='#{q.id}' #{c.quelle.to_s == q.id.to_s ? 'selected=\"selected\"' : nil}>#{id == q.id.to_s ? char6 : q.char6}</option>"
					end
					@html += "</select>"
					page.replace_html "source_#{c.id}", @html 
					@html = ""
	   			  end
	   			  update_quelle = 0
		      	end
	   	else
			if params[:source][:enable].nil?
				params[:source][:enable] = 0
			end
			@source.update_attributes(params[:source])
	   		kr_id = params[:kr_id]
	   		if !params[:source][:char6].nil? && @source.char6 != params[:source][:char6]
	      			id = params[:id]
	      			char6 = params[:source][:char6]
		        	@kreuzschiene = Kreuzschiene.find(kr_id)
	   			@cloneinputs = Source.find_all_by_cloneinput(params[:id])
	   			@cloneinputs.each do |c|
	   				@html = "<center><a style='text-decoration: none;' onclick='new Ajax.Request(\"/sources/updateCloneInput\", {asynchronous:true, evalscripts:true, method:\"post\",parameters: {id: #{params[:kr_id]}, source_id: #{c.id}}});' href='Javascript:void(0)'> #{params[:source][:char6]} </a></center>"
	   				page.replace_html "cloneinput_#{c.id}", @html 
	   			end	


	   			@quelle = Source.find_all_by_matrix_and_kreuzschiene_id(@kreuzschiene.name, kr_id)
	   			@quelle_list = @kreuzschiene.getSourceQuelle 

	   			@quelle.each do |c|
	   				@html = "<select class='ibtTableSelectBox' id='source_quelle' name='source[quelle]' onchange='document.getElementById(\"submitchangeitem#{c.id}\").click();' >
	   				<option value='' >&nbsp;</option> "
	   				@quelle_list.each do |q|
	   					@html += "<option value='#{q.id}' #{c.quelle.to_s == q.id.to_s ? 'selected=\"selected\"' : nil}>#{id == q.id.to_s ? char6 : q.char6}</option>"
	   				end
	   				@html += "</select>"
	   				page.replace_html "source_#{c.id}", @html 
	   				@html = ""
   
	   			end
	   		else
	   			@source.update_attributes(params[:source])
	   		end
	   		@kreuzschiene = Kreuzschiene.find(kr_id)
	   		@kr_all = Kreuzschiene.find_all_by_system_id(@system.id, :select => "id")
	   		@kr_ids = []
	   		@kr_all.each do |k|
	   			@kr_ids << k.id
	   		end
	   		@kr_ids = @kr_ids.join(",")
	   		@sources = Source.find_all_by_par_matrix_and_par_quelle(@kreuzschiene.intnummer, @source.intnummer, :conditions => ["kreuzschiene_id in (#{@kr_ids})"])
	   		@sources.each do |s|
		   		s.update_attributes(params[:source])
	   		end
		end

		if update_quelle == 1
			@page = "quellen" 
			prev_source = Source.find(@source.id-1)
			next_val = Option.getNextOption.value
			if prev_source && prev_source.matrix.to_i == @source.matrix.to_i
				if next_val == "N+1"
					@source.update_attributes(:quelle => prev_source.quelle.to_i+1)
				else
					@source.update_attributes(:quelle => prev_source.quelle)
				end
			else
				last_quelle = Source.getLastQuelle(@source.kreuzschiene_id, @source.matrix)
				if last_quelle && !last_quelle.quelle.nil?
					if next_val == "N+1"
						@source.update_attributes(:quelle => (last_quelle.quelle.to_i+1).to_s)
					else
						@source.update_attributes(:quelle => last_quelle.quelle)
					end
				end
			end
			page.replace_html "source_#{@source.id}", :partial => "kreuzschienes/quelle_select", :locals => {:source => @source, :page => @page}
		end

		if update_mx_senke == 1
			@page = "quellen"
			if @source.intnummer.to_i !=1
				prev_source = Source.find(@source.id-1)
				next_val = Option.getNextOption.value

				if prev_source.mx_matrix == @source.mx_matrix
					if next_val == "N+1"
						@source.update_attributes(:mx_senke => prev_source.mx_senke+1)
					else
						@source.update_attributes(:mx_senke => prev_source.mx_senke)
					end
				else
					last_quelle = Source.getLastSenke(@source.kreuzschiene_id, @source.mx_matrix)
					if last_quelle && !last_quelle.mx_senke.nil?
						if next_val == "N+1"
							@source.update_attributes(:mx_senke => last_quelle.mx_senke+1)
						else
							@source.update_attributes(:mx_senke => last_quelle.mx_senke)
						end
					end
				end
			end
			page.replace_html "source_sn_#{@source.id}", :partial => "kreuzschienes/senke_select", :locals => {:source => @source, :page => @page}
		end
   
		if update_clone_input == 1 
			@clone_source = Source.getCloneRecord(@source.intnummer, kv_id)
			if @clone_source.cloneinput.nil? || @clone_source.cloneinput.blank?
				@clone = '--'
			else
				@clone = Source.getCloneRecord(@clone_source.cloneinput.to_i, kv_id)
				@clone = @clone.char6
			end

			@html = "<center><a style='text-decoration: none;' onclick='new Ajax.Request(\"/sources/updateCloneInput\", {asynchronous:true, evalscripts:true, method:\"post\",parameters: {id: #{kv_id}, source_id: #{@source.intnummer}}});' href='Javascript:void(0)'> #{@clone} </a></center>"
			page.replace_html "cloneinput_#{@source.id}", @html 
		end

		if update_par_matrix == 1
			updt_par_matrix = false 
			updt_par_quelle = false
			next_val = Option.getNextOption.value

			if params[:source][:par_matrix] != @source.par_matrix
				updt_par_matrix = true
			end

			if params[:source][:par_quelle] != @source.par_quelle
				updt_par_quelle = true
			end

			@source.update_attribute('par_matrix',params[:source][:par_matrix])
			if @source.intnummer.to_i != 1
				last_par_quelle = Source.find_by_kreuzschiene_id_and_par_matrix_and_intnummer(@source.kreuzschiene_id, @source.par_matrix, @source.intnummer.to_i-1)
			else
				last_par_quelle = Source.find_by_kreuzschiene_id_and_par_matrix(@source.kreuzschiene_id, @source.par_matrix)
			end
			if params[:source][:par_quelle].nil? && !params[:source][:par_matrix].nil?
				if last_par_quelle && !last_par_quelle.par_quelle.nil?
					if next_val == "N+1"
						@source.update_attributes(:par_quelle => last_par_quelle.par_quelle+1)
					else
						@source.update_attributes(:par_quelle => last_par_quelle.par_quelle)
					end
				end
			else
				if next_val == "N+1" && !params[:source][:par_quelle].nil? && !params[:source][:par_quelle].blank?
					if params[:source][:par_quelle] != last_par_quelle.par_quelle+1
						@source.update_attributes(:par_quelle => params[:source][:par_quelle])
					else
						@source.update_attributes(:par_quelle => last_par_quelle.par_quelle+1)
					end
				else
					@source.update_attributes(:par_quelle => params[:source][:par_quelle])
				end
			end
			@page = "quellen"
			@kreuzschiene = Kreuzschiene.find_by_system_id_and_intnummer(@system.id, @source.par_matrix)
			if (!@source.par_quelle.nil? || !params[:source][:par_quelle].nil?) && (!updt_par_quelle || updt_par_matrix) && !@kreuzschiene.nil? 
				@source = Source.find(params[:id])
				if !@source.par_matrix.nil? && !@source.par_quelle.nil?
					@par_source = Source.find_by_kreuzschiene_id_and_intnummer(@kreuzschiene.id, @source.par_quelle)
					@source.update_attributes(:name5stellig  => @par_source.name5stellig, :name4stellig  => @par_source.name4stellig, :char6 => @par_source.char6, :char10 => @par_source.char10 , :comment => @par_source.comment, :cloneinput => @par_source.cloneinput, :tallybit  => @par_source.tallybit, :matrix => @par_source.matrix, :quelle => @par_source.quelle, :mx_matrix => @par_source.mx_matrix, :mx_senke => @par_source.mx_senke, :enable => @par_source.enable)
				end
				@quelle_list = @kreuzschiene.getSourceQuelle 
				@html = "<select class='ibtTableSelectBox' id='source_par_quelle' name='source[par_quelle]' onchange='document.getElementById(\"submitchangeitem#{@source.id}\").click();' >
				<option value='' >&nbsp;</option> "
				@quelle_list.each do |q|
					@html += "<option value='#{q.intnummer}' #{@source.par_quelle.to_i == q.id ? 'selected=\"selected\"' : nil}>#{id == q.id.to_s ? char6 : q.char6}</option>"
				end
				@html += "</select>"
				page.replace_html "source_par_#{@source.id}", @html 
				if !@kreuzschiene.nil?
					if @source.par_matrix.nil? && @source.par_quelle.nil?
						page.replace_html "source_row_#{@source.id}", :partial => "kreuzschienes/source_row_editable", :locals => {:source => @source, :kv_nr => @kreuzschiene.id}
					else
						page.replace_html "source_row_#{@source.id}", :partial => "kreuzschienes/source_row_non_editable", :locals => {:source => @source, :kv_nr => @kreuzschiene.id}
					end
				else
					@kreuzschiene = Kreuzschiene.find_by_system_id_and_id(@system.id, params[:kr_id])
					page.replace_html "source_row_#{@source.id}", :partial => "kreuzschienes/source_row_editable", :locals => {:source => @source, :kv_nr => @kreuzschiene.id}
				end
			else		
				
				@kreuzschiene = Kreuzschiene.find_by_system_id_and_id(@system.id, params[:kr_id])
				if @source.par_matrix.nil? && @source.par_quelle.nil?
					page.replace_html "source_row_#{@source.id}", :partial => "kreuzschienes/source_row_editable", :locals => {:source => @source, :kv_nr => @kreuzschiene.id}
				else
					@quelle_list = @kreuzschiene.getSourceQuelle 
					@html = "<select class='ibtTableSelectBox' id='source_par_quelle' name='source[par_quelle]' onchange='document.getElementById(\"submitchangeitem#{@source.id}\").click();' >
					<option value='' >&nbsp;</option> "
					@quelle_list.each do |q|
						@html += "<option value='#{q.intnummer}' #{@source.par_quelle.to_i == q.id ? 'selected=\"selected\"' : nil}>#{id == q.id.to_s ? char6 : q.char6}</option>"
					end
					@html += "</select>"
					page.replace_html "source_par_#{@source.id}", @html 
				end
			end
		end
	end
  end


  def setChangeAll
	if params[:opt] == "yes"
	  session[:QUELLEN_CHANGE_ALL] = 1 
	else
	  session[:QUELLEN_CHANGE_ALL] = 0
	end

	render :update do |page|
	end
  end

  def updateCloneInput
	@kreuzschiene = Kreuzschiene.find(params[:id])
	@source = Source.getCloneRecord(params[:source_id], @kreuzschiene.id)
	@ch6 = []
	@ch6.push("")

	@page = "quellen"
	prev_source = Source.find(@source.id-1)
	next_val = Option.getNextOption.value

	if next_val == "Enable" and !prev_source.cloneinput.nil?
		@source.update_attributes(:cloneinput => "#{prev_source.cloneinput.to_i + 1}")
	else
		@source.update_attributes(:cloneinput => "#{prev_source.cloneinput}")
	end

	@html = "<select onchange='document.getElementById(\"submitchangeitem#{@source.id}\").click();' name='source[cloneinput]' id='source_cloneinput' class='ibtTableSelectBox'>"
	@html += "<option value=''></option>"
	if params[:display] == 'id'
		@kreuzschiene.getChar6.each do |e|
			@html += "<option value='#{e.intnummer}' #{@source.cloneinput.to_s == e.intnummer.to_s ? selected='selected' : nil}>#{e.intnummer}</option>"
		end
	else
		@kreuzschiene.getChar6.each do |e|
			@html += "<option value='#{e.intnummer}' #{@source.cloneinput.to_s == e.intnummer.to_s ? selected='selected' : nil}>#{e.char6}</option>"
		end
	end
	@html += "</select>"

	render :update do |page|
		page.replace_html "cloneinput_#{@source.id}", @html 
	end
  end

  def dropdowns
	@system = System.find(cookies[:system_id])
	@id = params[:id]
	@typesource = Typesource.find(@id)
	@update_matrix = 0

	if @typesource.matrix.nil? && @typesource.bediengeraet.bdtype_id == 3
		@typesource.update_attributes(:matrix => @typesource.bediengeraet.normalquellen_kv_id) 
		@update_matrix = 1
		@kvlink = Kreuzschiene.getMatrix(@typesource.matrix, @system.id)

		if session[:display].nil? || session[:display]=='name' 
			@kvtitle = @kvlink.name 
		else
			@kvtitle = @kvlink.intnummer
		end
	end

	if !params[:bediengeraets].nil? && !params[:bediengeraets][:kv].nil?
		if !params[:bediengeraets][:kv].blank?
			@kv = Kreuzschiene.getMatrix(params[:bediengeraets][:kv], @system.id)
			@kv_val = @kv.id
			@typesource.update_attributes(:matrix => @kv.intnummer)
		else
			@kv = nil
			@kv_val = nil
		end
	else
		@kv = Kreuzschiene.getMatrix(params[:kv], @system.id)
		@kv_val = @kv.id if @kv #params[:kv]
	end

	prev_source = Typesource.find(@id.to_i-1) if @typesource.tasten_id !=1
	next_val = Option.getNextOption.value


	if @typesource.bediengeraet.bdtype_id != 3
		if prev_source
			if next_val == "N+1" and !prev_source.source_id.nil?
				@typesource.update_attributes(:source_id => prev_source.source_id+1)
			elsif next_val == "ASCII+1" and !prev_source.source_id.nil?
				@source = Source.find_by_kreuzschiene_id_and_intnummer(@kv_val, prev_source.source_id)		
				if !@source.nil?
					int = @source.name5stellig.match(/\d+/)[0]
					if int.first!="0"
						name = int.to_i + 1
					else
						name = "0"+(int.to_i + 1).to_s
					end
					name5stellig = @source.name5stellig.gsub(int.to_s, name.to_s)
					@new_source = Source.find_by_kreuzschiene_id_and_name5stellig(@kv_val, name5stellig)					
					if !@new_source.nil?
						@typesource.update_attributes(:source_id => @new_source.intnummer)
					else
						@typesource.update_attributes(:source_id => prev_source.source_id)
					end
				end
			else
				@typesource.update_attributes(:source_id => prev_source.source_id)
			end
		end
	else
		if @typesource.tasten_id !=1
			if prev_source.matrix == @typesource.matrix
				if next_val == "N+1"
					@typesource.update_attributes(:source_id => prev_source.source_id+1)
				elsif next_val == "ASCII+1"
					@source = Source.find_by_kreuzschiene_id_and_intnummer(@kv_val, prev_source.source_id)		
					if !@source.nil?
						int = @source.name5stellig.match(/\d+/)[0]
						if int.first!="0"
							name = int.to_i + 1
						else
							name = "0"+(int.to_i + 1).to_s
						end
						name5stellig = @source.name5stellig.gsub(int.to_s, name.to_s)
						@new_source = Source.find_by_kreuzschiene_id_and_name5stellig(@kv_val, name5stellig)					
						if !@new_source.nil?
							@typesource.update_attributes(:source_id => @new_source.intnummer)
						else
							@typesource.update_attributes(:source_id => prev_source.source_id)
						end
					end
				else
					@typesource.update_attributes(:source_id => prev_source.source_id)
				end
			else
				last_quelle = Typesource.getLastQuelle(@typesource.bediengeraet_id, @typesource.matrix)
				if last_quelle && !last_quelle.source_id.nil?
					if next_val == "N+1"
						@typesource.update_attributes(:source_id => last_quelle.source_id+1)
					elsif next_val == "ASCII+1"
						@source = Source.find_by_kreuzschiene_id_and_intnummer(@kv_val, prev_source.source_id)		
						if !@source.nil?
							int = @source.name5stellig.match(/\d+/)[0]
							if int.first!="0"
								name = int.to_i + 1
							else
								name = "0"+(int.to_i + 1).to_s
							end
							name5stellig = @source.name5stellig.gsub(int.to_s, name.to_s)
							@new_source = Source.find_by_kreuzschiene_id_and_name5stellig(@kv_val, name5stellig)					
							if !@new_source.nil?
								@typesource.update_attributes(:source_id => @new_source.intnummer)
							else
								@typesource.update_attributes(:source_id => prev_source.source_id)
							end
						end
					else
						@typesource.update_attributes(:source_id => last_quelle.source_id)
					end
				end
			end
		end
	end

  end

  def kv_dropdowns
	panel = Typesource.find(params[:id])
	panel.update_attributes(:matrix => panel.bediengeraet.normalquellen_kv_id) if panel.matrix.nil?
	if session[:display].nil? || session[:display]=='name' then
		@kv = Kreuzschiene.find(:all, :conditions => ["system_id=? and name!=''", cookies[:system_id]], :order => "intnummer").map {|u| [u.name, u.intnummer]}
	else
		@kv = Kreuzschiene.find(:all, :conditions=>["system_id=? and name!=''", cookies[:system_id]], :order=>"intnummer").map {|u| [u.intnummer, u.intnummer]}
	end
  end

  def get_matrix
	@source = Source.find(params[:id])
	if session[:display].nil? || session[:display]=='name' then
		@kv = Kreuzschiene.find(:all, :conditions => ["system_id=? and name!=''", cookies[:system_id]], :order => "intnummer").map {|u| [u.name, u.intnummer]}
	else
		@kv = Kreuzschiene.find(:all, :conditions=>["system_id=? and name!=''", cookies[:system_id]], :order=>"intnummer").map {|u| [u.intnummer, u.intnummer]}
	end
	render :update do |page|
		page.replace_html "source_matrix#{@source.id}", :partial => "kreuzschienes/get_matrix"
	end
  end

  def get_mx_matrix
	@source = Source.find(params[:id])
	if session[:display].nil? || session[:display]=='name' then
		@kv = Kreuzschiene.find(:all, :conditions => ["system_id=? and name!=''", cookies[:system_id]], :order => "intnummer").map {|u| [u.name, u.intnummer]}
	else
		@kv = Kreuzschiene.find(:all, :conditions=>["system_id=? and name!=''", cookies[:system_id]], :order=>"intnummer").map {|u| [u.intnummer, u.intnummer]}
	end
	render :update do |page|
		page.replace_html "source_mx_matrix#{@source.id}", :partial => "kreuzschienes/get_mx_matrix"
	end
  end

  def get_par_matrix
	@source = Source.find(params[:id])
	if session[:display].nil? || session[:display]=='name' then
		@kv = Kreuzschiene.find(:all, :conditions => ["system_id=? and name!=''", cookies[:system_id]], :order => "intnummer").map {|u| [u.name, u.intnummer]}
	else
		@kv = Kreuzschiene.find(:all, :conditions=>["system_id=? and name!=''", cookies[:system_id]], :order=>"intnummer").map {|u| [u.intnummer, u.intnummer]}
	end
	render :update do |page|
		page.replace_html "source_par_matirx#{@source.id}", :partial => "kreuzschienes/get_par_matrix"
	end
  end

  def get_channel
	@source = Source.find(params[:id])
	render :update do |page|
		page.replace_html "source_channel#{@source.id}", :partial => "kreuzschienes/get_channel"
	end
  end

  def get_family
	@source = Source.find(params[:id])
	if @source.intnummer != 1
  	prev_source = Source.find(@source.id-1)
  	@source.update_attribute("family_id",prev_source.family_id)
	end
	if session[:display].nil? || session[:display]=='name' then
		@families = Family.find(:all, :order => "nummer").map {|u| [u.name, u.nummer]}
	else
		@families = Family.find(:all, :order => "nummer").map {|u| [u.nummer, u.nummer]}
	end
	render :update do |page|
		page.replace_html "source_family_id#{@source.id}", :partial => "kreuzschienes/get_family"
	end
  end

  def get_mx_senke
	@source = Source.find(params[:row])
	prev_source = Source.find(@source.id-1)
	next_val = Option.getNextOption.value

	if prev_source.mx_matrix == @source.mx_matrix
		if next_val == "N+1"
			@source.update_attributes(:mx_senke => prev_source.mx_senke+1)
		else
			@source.update_attributes(:mx_senke => prev_source.mx_senke)
		end
	else
		last_quelle = Source.getLastSenke(@source.kreuzschiene_id, @source.mx_matrix)
		if last_quelle && !last_quelle.mx_senke.nil?
			if next_val == "N+1"
				@source.update_attributes(:mx_senke => last_quelle.mx_senke+1)
			else
				@source.update_attributes(:mx_senke => last_quelle.mx_senke)
			end
		end
	end

	render :update do |page|
		page.replace_html "source_sn_#{@source.id}", :partial => "kreuzschienes/senke_select"
	end
  end


  def get_quelle
	@page = "quellen"
	@source = Source.find(params[:row])
	next_val = Option.getNextOption.value
	prev_source = Source.find(@source.id-1)

	if prev_source.matrix.to_i == @source.matrix.to_i
		if next_val == "N+1"
			@source.update_attributes(:quelle => prev_source.quelle.to_i+1)
		else
			@source.update_attributes(:quelle => prev_source.quelle)
		end
	else
		last_quelle = Source.getLastQuelle(@source.kreuzschiene_id, @source.matrix)
		if last_quelle && !last_quelle.quelle.nil?
			if next_val == "N+1"
				@source.update_attributes(:quelle => last_quelle.quelle.to_i+1)
			else
				@source.update_attributes(:quelle => last_quelle.quelle)
			end
		end
	end

	render :update do |page|
		page.replace_html "source_#{@source.id}", :partial => "kreuzschienes/quelle_select"
	end
  end

  def get_par_quelle
	@page = "quellen"
	@source = Source.find(params[:row])
	next_val = Option.getNextOption.value
	prev_source = Source.find(@source.id-1)
	
	if prev_source.par_matrix.to_i == @source.par_matrix.to_i
		if next_val == "N+1"
			@source.update_attributes(:par_quelle => prev_source.par_quelle.to_i+1)
		else
			@source.update_attributes(:par_quelle => prev_source.par_quelle)
		end
	else
		last_quelle = Source.getLastQuelle(@source.kreuzschiene_id, @source.matrix)
		if last_quelle && !last_quelle.quelle.nil?
			if next_val == "N+1"
				@source.update_attributes(:par_quelle => last_quelle.quelle.to_i+1)
			else
				@source.update_attributes(:par_quelle => last_quelle.quelle)
			end
		end
	end
	render :update do |page|
		page.replace_html "source_par_#{@source.id}", :partial => "kreuzschienes/par_quelle_select"
	end

  end

  def get_tally
	@page = "quellen"
	@tally = getTallyCollection

	@source = Source.find(params[:row])
	next_val = Option.getNextOption.value
	prev_source = Source.find(@source.id-1)

	if next_val == "N+1" && !prev_source.tallybit.nil?
		@source.update_attributes(:tallybit => "#{prev_source.tallybit.to_i+1}")
	else
		@source.update_attributes(:tallybit => prev_source.tallybit)
	end

	render :update do |page|
		page.replace_html "source_tally#{@source.id}", :partial => "kreuzschienes/tallybit_select"
	end
  end

  def get_hlsd
	field = params[:field]
	@page = params[:page]

	@source = Source.find(params[:row])
	next_val = Option.getNextOption.value
	prev_source = Source.find(@source.id-1) if @source.intnummer != 1

	@signals = SignalQuellen.getQuellenSignals.map{|u| [u.title, u.intnummer]} if @page == "quellen"
	@signals = SignalSenken.getSenkenSignals.map{|u| [u.title, u.intnummer]}  if @page == "senken"
	@subclass = getHLSDCollection
	@component = getHLSDCollection
	@subcomponent = getHLSDCollection 

	@source.update_attributes(:signal => prev_source.signal, :subclass => prev_source.subclass, :subcomponent => prev_source.subcomponent) if prev_source

	if prev_source
		if next_val == "N+1" && !prev_source.component.nil?
			@source.update_attributes(:component => prev_source.component+1) 
		else
			@source.update_attributes(:component => prev_source.component)
		end
	end

	render :update do |page|
		page.replace_html "source_signal#{@source.id}", :partial => "kreuzschienes/hlsd_select", :locals => {:field => "signal"}
		page.replace_html "source_subclass#{@source.id}", :partial => "kreuzschienes/hlsd_select", :locals => {:field => "subclass"}
		page.replace_html "source_component#{@source.id}", :partial => "kreuzschienes/hlsd_select", :locals => {:field => "component"}
		page.replace_html "source_subcomponent#{@source.id}", :partial => "kreuzschienes/hlsd_select", :locals => {:field => "subcomponent"}
	end

  end
   
   def fetch_quelle
      @source = Source.find(params[:source_id])
      par_matrix = params[:matrix] 
      par_quelle = params[:quelle]
      @families = Family.find(:all)
      kv_nr = params[:kreuzschiene_id]
      @kreuzschiene = Kreuzschiene.find(params[:kreuzschiene_id])
            
      
      source_quelle = Source.find(:first, :conditions => ['kreuzschiene_id = ? AND intnummer = ? ', params[:kreuzschiene_id], params[:quelle]])
      
      @source.update_attributes({:name4stellig => source_quelle.name4stellig,:name5stellig => source_quelle.name5stellig,:char6 => source_quelle.char6,:char10 => source_quelle.char10 ,:cloneinput => source_quelle.cloneinput ,:tallybit => source_quelle.tallybit,:channel => source_quelle.channel, :family_id => source_quelle.family_id,:matrix => source_quelle.matrix,:quelle => source_quelle.quelle,:mx_matrix => source_quelle.mx_matrix,:mx_senke => source_quelle.mx_senke,:comment => source_quelle.comment})
      
      @source.update_attribute("par_quelle",par_quelle.to_i)
      @source.update_attribute("par_matrix",par_matrix)
      
      render :update do |page|
         page.replace_html "source_row_#{@source.id}", :partial => "kreuzschienes/source_row", :locals => {:source => @source, :kv_nr => kv_nr}
      end
   end
   
  def get_red
	@page = "quellen"
	@tally = getTallyCollection

	@source = Source.find(params[:row])
	next_val = Option.getNextOption.value
	prev_source = Source.find(@source.id-1)

	if next_val == "N+1" && !prev_source.red.nil?
		@source.update_attributes(:tallybit => "#{prev_source.tallybit.to_i+1}")
	else
		@source.update_attributes(:tallybit => prev_source.tallybit)
	end

	render :update do |page|
		page.replace_html "source_red#{@source.id}", :partial => "kreuzschienes/tallybit_select"
	end
  end

  def get_green
	@page = "quellen"
	@tally = getTallyCollection

	@source = Source.find(params[:row])
	next_val = Option.getNextOption.value
	prev_source = Source.find(@source.id-1)

	if next_val == "N+1" && !prev_source.tallybit.nil?
		@source.update_attributes(:green => "#{prev_source.green.to_i+1}")
	else
		@source.update_attributes(:green => prev_source.tallybit)
	end

	render :update do |page|
		page.replace_html "source_green#{@source.id}", :partial => "kreuzschienes/green_select"
	end
  end

  def get_yellow
	@page = "quellen"
	@tally = getTallyCollection

	@source = Source.find(params[:row])
	next_val = Option.getNextOption.value
	prev_source = Source.find(@source.id-1)

	if next_val == "N+1" && !prev_source.tallybit.nil?
		@source.update_attributes(:yellow => "#{prev_source.yellow.to_i+1}")
	else
		@source.update_attributes(:yellow => prev_source.tallybit)
	end

	render :update do |page|
		page.replace_html "source_yellow#{@source.id}", :partial => "kreuzschienes/yellow_select"
	end
  end

  def get_blue
	@page = "quellen"
	@tally = getTallyCollection

	@source = Source.find(params[:row])
	next_val = Option.getNextOption.value
	prev_source = Source.find(@source.id-1)

	if next_val == "N+1" && !prev_source.tallybit.nil?
		@source.update_attributes(:blue => "#{prev_source.blue.to_i+1}")
	else
		@source.update_attributes(:blue => prev_source.tallybit)
	end

	render :update do |page|
		page.replace_html "source_blue#{@source.id}", :partial => "kreuzschienes/blue_select"
	end
  end

end
