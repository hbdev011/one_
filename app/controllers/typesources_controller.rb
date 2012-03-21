class TypesourcesController < ApplicationController
  layout "application", :except=>['update']

  def update

	@system = System.find(cookies[:system_id])
	@ts = Typesource.find(params[:id])
	to_set = params[:typesource][:source_id]
	matrix = params[:matrix]

	if to_set == "" then
	  to_set = 0
	  matrix = 0
	end

	if @ts.update_attributes(:source_id => to_set, :matrix => matrix)
	  flash[:notice] = 'Änderung wurde gespeichert'
	else
	  flash[:notice] = 'FEHLER'
	end

	render :partial => "byname", :locals => { :ts => @ts, :display => session[:display] }

  end

  def add_normal_quelle
	bd_id = params[:id]
	@panel_function = PanelFunction.find_by_bediengeraet_id(bd_id)
	line = params[:typesource][:add_field].to_i
	total = Typesource.getNormalQuelleCount(bd_id)
	rows = total[0].cnt.to_i-line
	cnt=0

	@sources = Typesource.find(:all, :conditions => ["bediengeraet_id =? AND tasten_id >= ? AND sourcetype =?",bd_id, line, "normal"], :limit => rows, :order => "tasten_id" )

	@new_row = Typesource.getNormalQuelle(bd_id, line)
	@new_row.update_attributes(:source_id => nil, :matrix => nil)

	if !@panel_function.nil?
		if @panel_function.family == 1 && @panel_function.audis == 1
			(rows).times{
				if Global::AUDIS_FAMILY_SHIFT_ARRAY_PANEL6.include?(line)
					line+=4
				else
					line+=1
				end					
				@next_row = Typesource.getNormalQuelle(bd_id, line)
				@next_row.update_attributes(:source_id => @sources[cnt].source_id, :matrix =>  @sources[cnt].matrix)
				cnt+=1
			}
		elsif @panel_function.family == 1
			(rows).times{
				if Global::AUDIS_FAMILY_SHIFT_ARRAY_PANEL6.include?(line)
					line+=3
				else
					line+=1
				end					
				@next_row = Typesource.getNormalQuelle(bd_id, line)
				@next_row.update_attributes(:source_id => @sources[cnt].source_id, :matrix =>  @sources[cnt].matrix)
				cnt+=1
			}
		elsif @panel_function.audis == 1
			(rows).times{
				if Global::AUDIS_ARRAY_PANEL6.include?(line)
					line+=2
				elsif Global::SHIFT_ARRAY_PANEL6.include?(line)
					line+=2
				else
					line+=1
				end	
				@next_row = Typesource.getNormalQuelle(bd_id, line)
				@next_row.update_attributes(:source_id => @sources[cnt].source_id, :matrix =>  @sources[cnt].matrix)
				cnt+=1
			}
		else
			(rows).times{
				line+=1
				@next_row = Typesource.getNormalQuelle(bd_id, line)
				@next_row.update_attributes(:source_id => @sources[cnt].source_id, :matrix =>  @sources[cnt].matrix)
				cnt+=1
			}
		end
	else
		(rows).times{
			line+=1
			@next_row = Typesource.getNormalQuelle(bd_id, line)
			@next_row.update_attributes(:source_id => @sources[cnt].source_id, :matrix =>  @sources[cnt].matrix)
			cnt+=1
		}
	end

	redirect_to :back
  end

  def add_split_quelle
	bd_id = params[:id]
	line = params[:typesource][:add_field].to_i
	total = Typesource.getSplitQuelleCount(bd_id)
	rows = total[0].cnt.to_i-line
	cnt=0

	@sources = Typesource.find(:all, :conditions => ["bediengeraet_id =? AND tasten_id >= ? AND sourcetype =?",bd_id, line, "split"], :limit => rows, :order => "tasten_id" )

	@new_row = Typesource.getSplitQuelle(bd_id, line)
	@new_row.update_attributes(:source_id => nil, :matrix => nil)

	(rows).times{
		line+=1
		@next_row = Typesource.getSplitQuelle(bd_id, line)
		@next_row.update_attributes(:source_id => @sources[cnt].source_id, :matrix =>  @sources[cnt].matrix)
		cnt+=1
	}

	redirect_to :back
  end

  def remove_normal_quelle
	bd_id = params[:id]
	@panel_function = PanelFunction.find_by_bediengeraet_id(bd_id)
	line = params[:typesource][:remove_field].to_i
	total = Typesource.getNormalQuelleCount(bd_id)
	rows = total[0].cnt.to_i-line
	cnt=0

	@sources = Typesource.find(:all, :conditions => ["bediengeraet_id =? AND tasten_id > ? AND sourcetype =?",bd_id, line, "normal"], :limit => rows, :order => "tasten_id" )

	if !@panel_function.nil?
		if @panel_function.family == 1 && @panel_function.audis == 1
			(rows).times{
				@next_row = Typesource.getNormalQuelle(bd_id, line)
				@next_row.update_attributes(:source_id => @sources[cnt].source_id, :matrix => @sources[cnt].matrix)
				if Global::AUDIS_FAMILY_SHIFT_ARRAY_PANEL6.include?(line)
					line+=4
				else
					line+=1
				end					
				cnt+=1
			}
		elsif @panel_function.family == 1
			(rows).times{
				@next_row = Typesource.getNormalQuelle(bd_id, line)
				@next_row.update_attributes(:source_id => @sources[cnt].source_id, :matrix => @sources[cnt].matrix)
				if Global::AUDIS_FAMILY_SHIFT_ARRAY_PANEL6.include?(line)
					line+=3
				else
					line+=1
				end					
				cnt+=1
			}
		elsif @panel_function.audis == 1
			(rows).times{
				@next_row = Typesource.getNormalQuelle(bd_id, line)
				@next_row.update_attributes(:source_id => @sources[cnt].source_id, :matrix => @sources[cnt].matrix)
				if Global::AUDIS_ARRAY_PANEL6.include?(line)
					line+=2
				elsif Global::SHIFT_ARRAY_PANEL6.include?(line)
					line+=2
				else
					line+=1
				end	
				cnt+=1
			}
		else
			(rows).times{
				@next_row = Typesource.getNormalQuelle(bd_id, line)
				@next_row.update_attributes(:source_id => @sources[cnt].source_id, :matrix => @sources[cnt].matrix)

				cnt+=1
				line+=1
			}
		end
	else
		(rows).times{
			@next_row = Typesource.getNormalQuelle(bd_id, line)
			@next_row.update_attributes(:source_id => @sources[cnt].source_id, :matrix => @sources[cnt].matrix)

			cnt+=1
			line+=1
		}
	end

	@last_row = Typesource.getNormalQuelle(bd_id, total[0].cnt.to_i)
	@last_row.update_attributes(:source_id => nil, :matrix => nil)

	redirect_to :back
  end

  def remove_split_quelle
	bd_id = params[:id]
	line = params[:typesource][:remove_field].to_i
	total = Typesource.getSplitQuelleCount(bd_id)
	rows = total[0].cnt.to_i-line
	cnt=0

	@sources = Typesource.find(:all, :conditions => ["bediengeraet_id =? AND tasten_id > ? AND sourcetype =?",bd_id, line, "split"], :limit => rows, :order => "tasten_id" )

	(rows).times{
		@next_row = Typesource.getSplitQuelle(bd_id, line)
		@next_row.update_attributes(:source_id => @sources[cnt].source_id, :matrix => @sources[cnt].matrix)

		cnt+=1
		line+=1
	}

	@last_row = Typesource.getSplitQuelle(bd_id, total[0].cnt.to_i)
	@last_row.update_attributes(:source_id => nil, :matrix => nil)

	redirect_to :back
  end

end
