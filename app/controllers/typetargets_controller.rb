class TypetargetsController < ApplicationController
  layout "application", :except=>['update']

  def update
  	@system = System.find(cookies[:system_id])
    @tt = Typetarget.find(params[:id])
    to_set = params[:typetarget][:target_id]
    matrix = params[:matrix]
    if to_set == "" then
      to_set = 0
    end

    if @tt.update_attributes(:target_id => to_set, :matrix => matrix)
      flash[:notice] = 'Änderung wurde gespeichert'
    else
      flash[:notice] = 'FEHLER'
    end

    render :partial => "byname", :locals => { :tt => @tt, :display => session[:display] }
  end
  
  def add_senke
	bd_id = params[:id]
	@panel_function = PanelFunction.find_by_bediengeraet_id(bd_id)
	line = params[:typetarget][:add_field].to_i
	total = Typetarget.getSenkeCount(bd_id)
	rows = total[0].cnt.to_i-line
	cnt=0

	@targets = Typetarget.find(:all, :conditions => ["bediengeraet_id =? AND tasten_id >= ?",bd_id, line], :limit => rows, :order => "tasten_id" )

	@new_row = Typetarget.getSenke(bd_id, line)
	@new_row.update_attributes(:target_id => nil, :matrix => nil)

	if !@panel_function.nil?
		if @panel_function.family == 1 && @panel_function.audis == 1
			(rows).times{
				if Global::AUDIS_FAMILY_SHIFT_ARRAY_PANEL5.include?(line)
					line+=4
				else
					line+=1
				end					
				@next_row = Typetarget.getSenke(bd_id, line)
				@next_row.update_attributes(:target_id => @targets[cnt].target_id, :matrix =>  @targets[cnt].matrix)
				cnt+=1
			}
		elsif @panel_function.family == 1
			(rows).times{
				if Global::AUDIS_FAMILY_SHIFT_ARRAY_PANEL5.include?(line)
					line+=3
				else
					line+=1
				end					
				@next_row = Typetarget.getSenke(bd_id, line)
				@next_row.update_attributes(:target_id => @targets[cnt].target_id, :matrix =>  @targets[cnt].matrix)
				cnt+=1
			}
		elsif @panel_function.audis == 1
			(rows).times{
				if Global::AUDIS_ARRAY_PANEL5.include?(line)
					line+=2
				elsif Global::SHIFT_ARRAY_PANEL5.include?(line)
					line+=2
				else
					line+=1
				end	
				@next_row = Typetarget.getSenke(bd_id, line)
				@next_row.update_attributes(:target_id => @targets[cnt].target_id, :matrix =>  @targets[cnt].matrix)
				cnt+=1
			}
		else
			(rows).times{
				line+=1
				if Global::SHIFT_ARRAY_PANEL5.include?(line)
					line+=1
				end
				@next_row = Typetarget.getSenke(bd_id, line)
				@next_row.update_attributes(:target_id => @targets[cnt].target_id, :matrix =>  @targets[cnt].matrix)
				cnt+=1
			}
		end
	else
		(rows).times{
			line+=1
			if Global::SHIFT_ARRAY_PANEL5.include?(line)
				line+=1
			end
			@next_row = Typetarget.getSenke(bd_id, line)
			@next_row.update_attributes(:target_id => @targets[cnt].target_id, :matrix =>  @targets[cnt].matrix)
			cnt+=1
		}
	end

	redirect_to :back
  end

  def remove_senke
	bd_id = params[:id]
	@panel_function = PanelFunction.find_by_bediengeraet_id(bd_id)
	line = params[:typetarget][:remove_field].to_i
	total = Typetarget.getSenkeCount(bd_id)
	rows = total[0].cnt.to_i-line
	cnt=0

	@targets = Typetarget.find(:all, :conditions => ["bediengeraet_id =? AND tasten_id > ?",bd_id, line], :limit => rows, :order => "tasten_id" )

	if !@panel_function.nil?
		if @panel_function.family == 1 && @panel_function.audis == 1
			(rows).times{
				@next_row = Typetarget.getSenke(bd_id, line)
				@next_row.update_attributes(:target_id => @targets[cnt].target_id, :matrix => @targets[cnt].matrix)
				if Global::AUDIS_FAMILY_SHIFT_ARRAY_PANEL5.include?(line)
					line+=4
				else
					line+=1
				end					
				cnt+=1
			}
		elsif @panel_function.family == 1
			(rows).times{
				@next_row = Typetarget.getSenke(bd_id, line)
				@next_row.update_attributes(:target_id => @targets[cnt].target_id, :matrix => @targets[cnt].matrix)
				if Global::AUDIS_FAMILY_SHIFT_ARRAY_PANEL5.include?(line)
					line+=3
				else
					line+=1
				end					
				cnt+=1
			}
		elsif @panel_function.audis == 1
			(rows).times{
				@next_row = Typetarget.getSenke(bd_id, line)
				@next_row.update_attributes(:target_id => @targets[cnt].target_id, :matrix => @targets[cnt].matrix)
				if Global::AUDIS_ARRAY_PANEL5.include?(line)
					line+=2
				elsif Global::SHIFT_ARRAY_PANEL5.include?(line)
					line+=2
				else
					line+=1
				end	
				cnt+=1
			}
		else
			(rows).times{
				@next_row = Typetarget.getSenke(bd_id, line)
				@next_row.update_attributes(:target_id => @targets[cnt].target_id, :matrix => @targets[cnt].matrix)

				cnt+=1
				line+=1
				if Global::SHIFT_ARRAY_PANEL5.include?(line)
					line+=1
				end
			}
		end
	else
		(rows).times{
			@next_row = Typetarget.getSenke(bd_id, line)
			@next_row.update_attributes(:target_id => @targets[cnt].target_id, :matrix => @targets[cnt].matrix)

			cnt+=1
			line+=1
			if Global::SHIFT_ARRAY_PANEL5.include?(line)
				line+=1
			end
		}
	end

	@last_row = Typetarget.getSenke(bd_id, total[0].cnt.to_i)
	@last_row.update_attributes(:target_id => nil, :matrix => nil)

	redirect_to :back
  end

end
