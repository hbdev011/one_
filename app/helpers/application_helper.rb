# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def formatstring(str, len)
	begin
	  returner = ('"' + str.ljust(len) + '"').to_s
	rescue
	  returner = ('"' + "".ljust(len) + '"').to_s
	end
  end

  def formatnumber2(nbr)
	return "0" + nbr.to_i.to_s if nbr.to_i<10
	return "00" if nbr.nil? or nbr==0
	return nbr.to_s
  end

  def formatnumber3(nbr)
	return "000" if nbr.nil? || nbr.blank?
	return "00" + nbr.to_s if nbr.to_i<10
	return "0" + nbr.to_s if nbr.to_i<100
	return nbr.to_s
  end

  def getTypeSourceMatrix(source_matrix, panel_matrix, system_id)
	system = System.find(cookies[:system_id])
	if source_matrix.blank? || source_matrix.nil?
		return panel_matrix
	else
		#kv = Kreuzschiene.getMatrix(source_matrix, system)
		return source_matrix #kv.intnummer
	end
  end

  def getTypeTargetMatrix(target_matrix, panel_matrix, system_id)
	if target_matrix.blank? || target_matrix.nil?
		return panel_matrix
	else
		kv = Kreuzschiene.find_by_intnummer_and_system_id(target_matrix, system_id)
		return kv.intnummer
	end
  end

  def get_port_user(unit, port)
	kv_m = Kreuzschiene.find(:first, :conditions => ["unit =? and port =? and system_id =?", unit, port, @system], :select => "id, name")
	if kv_m
		result = kv_m.name
	else
		kv_s = Kreuzschiene.find(:first, :conditions => ["unit2 =? and port2 =? and system_id =?", unit, port, @system], :select => "id, name")
		if kv_s
			result = kv_s.name
		else
			dv = Device.find(:first, :conditions => ["unit =? and port =? and system_id =?", unit, port,  @system], :select => "id, name")
			if dv
				result = dv.name
			else
				bd = Bediengeraet.find(:first, :conditions => ["unit =? and port =? and system_id =?", unit, port, @system], :select => "id, name8stellig, name4stellig")
				if bd
					result = bd.name8stellig
				else
					result = "&nbsp;"
				end
			end
		end
	end
	if result.nil? || result.blank?
		result = "<font style='color:red;'>ERROR</font>"
	end
	return result
  end

  def get_panel_spinner_height(panel_type)
  	case panel_type
		when 1
			return 200
		when 2
			return 1140
		when 3
			return 1750
		when 4
			return 160
		when 5
			return 1540
	end
  end

  def get_tt_input(nummer)
	system = System.find(cookies[:system_id])
	# input, node, input signal
	input = GpInput.find_by_system_id_and_value(system.id, nummer, :select => "id, name")
	if input
		return (!input.name.nil? && !input.name.blank?)? input.name : "____"
	else
		input = GpNode.find_by_value(nummer, :select => "id, name")
		if input
			return (!input.name.nil? && !input.name.blank?)? input.name : "____"
		else
			input = GpInSignal.find_by_value(nummer, :select => "id, name")
			if input
				return (!input.name.nil? && !input.name.blank?)? input.name : "____"
			else
				return "____"
			end
		end
	end
  end

  def get_tt_output(nummer)
	system = System.find(cookies[:system_id])
	# output, node, output signal
	output = GpOutput.find_by_system_id_and_value(system.id, nummer, :select => "id, name")
	if output
		return (!output.name.nil? && !output.name.blank?)? output.name : "____"
	else
		output = GpNode.find_by_value(nummer, :select => "id, name")
		if output
			return (!output.name.nil? && !output.name.blank?)? output.name : "____"
		else
			output = GpOutSignal.find_by_value(nummer, :select => "id, name")
			if output
				return (!output.name.nil? && !output.name.blank?)? output.name : "____"
			else
				return "____"
			end
		end
	end
  end

  def setup(f)
    if session[:display].nil? || session[:display]=='name' then

		          if f.source_id then
			          begin
			            @sourcename = f.sourcename
			          rescue
			            @sourcename = "___"
			          end
		          end

		          if f.target_id then
			          begin
			            @targetname = f.targetname
			          rescue
			            @targetname = "___"
			          end
		          end

		        else

		          if f.source_id>0 then
			          begin
			            @sourcename = f.source.intnummer
			          rescue
			            @sourcename = "___"
			          end
		          end

		          if f.target_id>0 then
			          begin
			            @targetname = f.target.intnummer
			          rescue
			             @targetname = "___"
			          end
		          end
		        end

		        @sourcename = "___" if @sourcename.nil? or @sourcename==""
		        @targetname = "___" if @targetname.nil? or @targetname==""

		        @kid = 0
		        @kid = f.kreuzschiene.id unless f.kreuzschiene.nil?
  end

end

