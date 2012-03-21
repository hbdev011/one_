class FamilyController < ApplicationController
	def index
		@families = Family.find(:all, :order => 'position, id ASC')
		@system_colors = SystemColor.find(:all)
		@quellen_font = Global::QUELLEN_FONT
    @label = Option.find_by_title('family_label')
    @font = Option.find_by_title('family_font')
		if request.post?
			@system = System.find(cookies[:system_id])
			FamilyPanel.delete_all("system_id =  #{@system.id}")
			@matrix = Kreuzschiene.find_all_by_system_id(@system, :conditions => ["kr_type != ?",'MIXER'], :order => 'intnummer ASC')

			@matrix.each do |matrix|
				@sources = Source.find_all_by_kreuzschiene_id(matrix.id, :conditions => "sources.family_id != NULL or sources.family_id != 0", :joins => "left join families on families.nummer = sources.family_id", :select => "sources.*", :order => "families.position, sources.id ASC")
				@sources.each do |source|
						FamilyPanel.create(:system_id => @system.id, :matrix => matrix.intnummer, :quellen => source.intnummer, :family => source.family_id, :source_type => "source")
				end
			end

			@matrix.each do |matrix|
				@targets = Target.find_all_by_kreuzschiene_id(matrix.id, :conditions => "targets.family_id != NULL or targets.family_id != 0", :joins => "left join families on families.nummer = targets.family_id", :select => "targets.*", :order => "families.position, targets.id  ASC")
				@targets.each do |target|
						FamilyPanel.create(:system_id => @system.id, :matrix => matrix.intnummer, :quellen => target.intnummer, :family => target.family_id, :source_type => "target")
				end
			end

			@families_arr = Family.find(:all)
			family_arr = {}
			@families_arr.each do |family|
				family_arr[family.nummer] = family.name
			end
			@html = "<table width='50%'>"
			@html << "<tr><td colspan='2' style='font-size:15px' align='center'><strong>Quellen</strong></td></tr>"
			@html << "<tr><td colspan='2'></td></tr>"
			@matrix.each do |kv|
				@family_member = FamilyPanel.find_all_by_system_id_and_matrix_and_source_type(@system.id, kv.intnummer, 'source', :order => "id ASC")
				if !@family_member.nil? && !@family_member.blank?
					@html << "<tr><td colspan='2' style='font-size:12px' align='center'><strong>Matrix: #{kv.name}</strong></td></tr>"
					@family_member.each do |fm|
						@html << "<tr><td>#{get_quelle(fm.quellen, kv.id)}</td><td>#{family_arr[fm.family]}</td></tr>"
					end
				end
			end

			@html << "<tr><td colspan='2' style='font-size:15px' align='center'><strong>Senken</strong></td></tr>"
			@html << "<tr><td colspan='2'></td></tr>"

			@matrix.each do |kv|
				@family_member = FamilyPanel.find_all_by_system_id_and_matrix_and_source_type(@system.id, kv.intnummer, 'target', :order => "id ASC")
				if !@family_member.nil? && !@family_member.blank?
					@html << "<tr><td colspan='2' style='font-size:12px' align='center'><strong>Matrix: #{kv.name}</strong></td></tr>"
					@family_member.each do |fm|
						@html << "<tr><td>#{get_senke(fm.quellen, kv.id)}</td><td>#{family_arr[fm.family]}</td></tr>"
					end
				end
			end
			@html << "</table>"
			flash[:notice] = "Family list updated Successfully"
		end

  end

	def create_family
		if request.post?
			@family = Family.new(params[:family])
			@family.nummer	= Family.maximum(:nummer).to_i+1
			@family.position	= Family.maximum(:position).to_i+1
			if @family.save
				redirect_to :action => 'index'
			end
		end
	end

	def update
		if request.post?
			@family = Family.find(params[:id])
			if @family.update_attributes(params[:family])
				flash[:notice] = "Family updated successfully"
				if request.xhr?
				  render :nothing => true
			  else		  
  				redirect_to :action => 'index'
				end
			end
		end
	end

	def delete_family
    if params[:confirmed]
      if Family.find_by_nummer(params[:id]).destroy()
        Target.update_all("family_id = 0","family_id = #{params[:id]}")
        Source.update_all("family_id = 0","family_id = #{params[:id]}")
        flash[:notice] = "Family deleted successfully"
        redirect_to :action => 'index'
      end
    else
      count = Target.count(:conditions => ['family_id = ?', params[:nummer]]) + Source.count(:conditions => ['family_id = ?', params[:nummer]])
      if count > 0
        render :text => (true) and return false
      else
        render :text => false and return false
      end
    end
	end

	def sort
		params[:family].each_with_index do |id, index|
			Family.update_all(['position=?', index+1], ['id=?', id])
		end

		render :update do |page|
			@families = Family.find(:all, :order => 'position, id ASC')
			@system_colors = SystemColor.find(:all)
			page.replace_html "family", :partial => "family_list"
		end
	end

	def family_panel
		if request.post?
			@system = System.find(params[:id])
			FamilyPanel.delete_all("system_id =  #{@system.id}")
			@matrix = Kreuzschiene.find_all_by_system_id(@system, :order => 'intnummer ASC')

			@matrix.each do |matrix|
				@sources = Source.find_all_by_kreuzschiene_id(matrix.id)
				@sources.each do |source|
					if source.family_id!=0 && !source.family_id.nil? && !source.family_id.blank?
						FamilyPanel.create(:system_id => @system.id, :matrix => matrix.intnummer, :quellen => source.intnummer, :family => source.family_id, :source_type => "source")
					end
				end
			end

			@matrix.each do |matrix|
				@targets = Target.find_all_by_kreuzschiene_id(matrix.id)
				@targets.each do |target|
					if target.family_id!=0 && !target.family_id.nil? && !target.family_id.blank?
						FamilyPanel.create(:system_id => @system.id, :matrix => matrix.intnummer, :quellen => target.intnummer, :family => target.family_id, :source_type => "target")
					end
				end
			end

			@families = Family.find(:all, :order => "position ASC")
			family_arr = {}
			@families.each do |family|
				family_arr[family.nummer] = family.name
			end
			@html = "<table width='50%'>"
			@html << "<tr><td colspan='2' style='font-size:15px' align='center'><strong>Quellen</strong></td></tr>"
			@html << "<tr><td colspan='2'></td></tr>"
			@matrix.each do |kv|
				@family_member = FamilyPanel.find_all_by_system_id_and_matrix_and_source_type(@system.id, kv.intnummer, 'source', :order => "quellen, family ASC")
				if !@family_member.nil? && !@family_member.blank?
					@html << "<tr><td colspan='2' style='font-size:12px' align='center'><strong>Matrix: #{kv.name}</strong></td></tr>"
					@family_member.each do |fm|
						@html << "<tr><td>#{get_quelle(fm.quellen, kv.id)}</td><td>#{family_arr[fm.family]}</td></tr>"
					end
				end
			end

			@html << "<tr><td colspan='2' style='font-size:15px' align='center'><strong>Senken</strong></td></tr>"
			@html << "<tr><td colspan='2'></td></tr>"

			@matrix.each do |kv|
				@family_member = FamilyPanel.find_all_by_system_id_and_matrix_and_source_type(@system.id, kv.intnummer, 'target', :order => "quellen, family ASC")
				if !@family_member.nil? && !@family_member.blank?
					@html << "<tr><td colspan='2' style='font-size:12px' align='center'><strong>Matrix: #{kv.name}</strong></td></tr>"
					@family_member.each do |fm|
						@html << "<tr><td>#{get_senke(fm.quellen, kv.id)}</td><td>#{family_arr[fm.family]}</td></tr>"
					end
				end
			end
			@html << "</table>"
			flash[:notice] = "Family list updated Successfully"
		end
	end

	def get_quelle(intnummer, id)
		return Source.find_by_intnummer_and_kreuzschiene_id(intnummer, id).name5stellig
	end

	def get_senke(intnummer, id)
		return Target.find_by_intnummer_and_kreuzschiene_id(intnummer, id).name5stellig
	end

	def get_color
	  if params[:id]
		  @color = SystemColor.find_by_nummer(params[:id]) 
		  render :text => "rgb(#{@color.red},#{@color.green},#{@color.blue})" and return false
	  else
	    render :nothing => true
	  end
	  
	end

	def save_font_values
	  option = Option.find_or_create_by_title("family_font")
	  option.update_attribute('value',params[:value])
	  render :text => "Font Saved!"
	end

	def save_label_values
	  option = Option.find_or_create_by_title("family_label")
	  option.update_attribute('value',params[:value])
    render :text => "Label Saved!"
	end
end
