class GpisController < ApplicationController

	require 'expression'


	def draw_tt
		@system = System.find(cookies[:system_id])
		exprs = InOutTable.get_exprs(@system.id)
	        exprs = exprs.map{|x| x if !x.boolean_expr.nil?}.compact
		@exprs_results = exprs.map{ |x| [x, parse_boolean_expr_for_tt(x.boolean_expr)]}

		#render :text => @exprs_results.inspect and return false
		render :layout => false
		#render :text => InOutTable.get_exprs("1").map{|y| (y.boolean_expr.inspect+" :<br/> "+y.function)+"\n" }.join("<br/><br/>") and return false
	end


	def ion_entry
		get_ion_list

		get_items
		@change_items = 0
		@system = System.find(cookies[:system_id])

		@calc = Expression.new(@system.id)

		if request.post? && params[:tab] == "logic"

			GpNode.destroy_all(:system_id => @system.id) # Remove existing Nodes
			Group.destroy_all(:system_id => @system.id) # Remove existing Groups

			InOutTable.delete_all(:system_id => @system.id) # Remove existing Groups

			# Prepare file content for compilation
			#
			clean_content
			@conf_file_name = "gpio.conf"
		elsif  params[:tab] == "logic"
			@exprs = InOutTable.get_exprs(@system.id)

    	    if File.exist?("#{RAILS_ROOT}/conf/#{cookies[:system_id]}/gpio.txt")
			    @file_name = "gpio.txt"
		    end
		    if File.exist?("#{RAILS_ROOT}/conf/#{cookies[:system_id]}/gpio.conf")
        		@conf_file_name = "gpio.conf"
		    end
			@singles = []
			@message = ""
			@tt_count = nil
		else

		    if File.exist?("#{RAILS_ROOT}/conf/#{cookies[:system_id]}/gpio.txt")
			    @file_name = "gpio.txt"
		    end
		    if File.exist?("#{RAILS_ROOT}/conf/#{cookies[:system_id]}/gpio.conf")
        		@conf_file_name = "gpio.conf"
		    end
		end
	end

	def get_items
		@in_type = {"Unit" => 1, "Panel" => 2}
		@invert = {"No" => 0, "Yes" => 1}
		@mode = {"Toggle" => 1, "Static" => 2, "Pulse" => 3}
		@options = {"Add Row at last" => 1, "Add N Rows at last" => 2, "Add Row on Position" => 3}
		@units = get_units
		@panels = (1..Global::MAX_PANEL).to_a
		@byte = (1..Global::MAX_BYTE).to_a
		@single = [1]
		@blank = []
		@rbtn = {"None" => 0, 1 => 1, 2 => 2, 3 => 3, 4 => 4, 5 => 5, 6 => 6, 7 => 7, 8 => 8}
		@bit = (0..16).to_a
	end

	def get_ion_list
		@system = System.find(cookies[:system_id])
		@inputs = GpInput.get_inputs(@system.id) if [nil, "input"].include? params[:tab]
		@outputs = GpOutput.get_outputs(@system.id) if params[:tab] == "output"
		@nodes = GpNode.get_nodes(@system.id) if params[:tab] == "node"
		@i_signals = GpInSignal.get_input_signals if params[:tab] == "in_signal"
		@o_signals = GpOutSignal.get_output_signals if params[:tab] == "out_signal"
	end

# ------------------ Input Section ------------------
# ---------------------------------------------------
	def options_input
		@system = System.find(cookies[:system_id])
		option = params[:input][:option]
		row = params[:input][:nummer]

		case option
			when '1'
				new_row = GpInput.add_last(@system.id)
			when '2'
				new_row = GpInput.add_last(@system.id, row.to_i)
			when '3'
				inputs = GpInput.find(:all, :conditions => ["system_id =? and intnummer >=?", @system.id, row.to_i])
				new_row = GpInput.add_last(@system.id)
				new_row = row

				row_input = GpInput.find_by_intnummer_and_system_id(row, @system.id)
				row_input.update_attributes(:name => nil, :unit => nil, :port => nil, :byte => nil, :bit => nil, :invert => 1, :radio => 0, :comment => nil, :i_type => 1) if row_input

				inputs.each do |n|
					next_input = GpInput.find_by_intnummer_and_system_id(n.intnummer+1, @system.id)
					next_input.update_attributes(:value => n.value+1, :name => n.name, :unit => n.unit, :port => n.port, :byte => n.byte, :bit => n.bit, :invert => n.invert, :radio => n.radio, :comment => n.comment, :i_type => n.i_type)
				end
		end
		redirect_to "/gpis/ion_entry?tab=input#input#{new_row}"
	end

	def update_input
		i_type = params[:input][:i_type]
		unit = params[:input][:unit]
		port = params[:input][:port]

		update_items = 0
		update_port = 0

		@input = GpInput.find(params[:id])

		if !port.blank? && port.to_i != @input.port
			html_id = "port6_#{@input.id}"
			opt = 6
			update_port = 1
		end

		if !i_type.blank? && @input.i_type != i_type.to_i
			update_items = 1
			get_items

			if i_type.to_i == 2
				@input.update_attributes(:i_type => 2, :port => 1, :bit => 1, :byte => 1)
			else
				@input.update_attributes(:i_type => 1, :port => nil, :bit => nil, :byte =>  nil)
			end
		end

		render :update do |page|
			if update_items == 1
				page.replace_html "input_row_#{@input.id}", :partial => "input_row"
			elsif update_port == 1
				@input.update_attributes(params[:input])
				page.replace_html "#{html_id}", :partial => "shared/port_listbox", :locals => {:show => "link", :opt => opt}
			else
				@input.update_attributes(params[:input])
			end
			page.replace_html "in_msg", "<font style='color:green;'>Eingabe erfolgreich aktualisiert</font>"
		end
	end

	def delete_input
		row = params[:id]
		delete_input_part(row)

		flash[:in_msg] = "<font style='color:green;'>Eingabe erfolgreich entfernt</font>"
		redirect_to "/gpis/ion_entry?tab=input#input#{row.to_i-1}"
	end

	def delete_input_part(row)
		inputs = GpInput.find(:all, :conditions => ["system_id =? and intnummer >?", @system.id, row.to_i], :select => "id, intnummer")

		row_input = GpInput.find_by_intnummer_and_system_id(row, @system.id)
		row_input.destroy

		inputs.each do |n|
			current_input = GpInput.find_by_intnummer_and_system_id(n.intnummer, @system.id, :select => "id, intnummer")
			current_input.update_attributes(:intnummer => n.intnummer-1)
		end
	end
# ----------------------------------------------------


# ------------------ Output Section ------------------
# ----------------------------------------------------
	def options_output
		@system = System.find(cookies[:system_id])
		option = params[:output][:option]
		row = params[:output][:nummer]

		case option
			when '1'
				new_row = GpOutput.add_last(@system.id)
			when '2'
				new_row = GpOutput.add_last(@system.id, row.to_i)
			when '3'
				outputs = GpOutput.find(:all, :conditions => ["system_id =? and intnummer >=?", @system.id, row.to_i])
				new_row = GpOutput.add_last(@system.id)
				new_row = row

				row_output = GpOutput.find_by_intnummer_and_system_id(row, @system.id)
				row_output.update_attributes(:name => nil, :active_name => nil, :inactive_name => nil, :unit => nil, :port => nil, :byte => nil, :bit => nil, :invert => 1, :mode => 2, :comment => nil, :o_type => 1) if row_output

				outputs.each do |n|
					next_output = GpOutput.find_by_intnummer_and_system_id(n.intnummer+1, @system.id)
					next_output.update_attributes(:value => n.value+1, :name => n.name, :active_name => n.active_name, :inactive_name => n.inactive_name, :unit => n.unit, :port => n.port, :byte => n.byte, :bit => n.bit, :invert => n.invert, :mode => n.mode, :comment => n.comment, :o_type => n.o_type)
				end
		end
		redirect_to "/gpis/ion_entry?tab=output#output#{new_row}"
	end

	def update_output
		o_type = params[:output][:o_type]
		unit = params[:output][:unit]
		port = params[:output][:port]

		update_items = 0
		update_port = 0

		@output = GpOutput.find(params[:id])

		if !port.blank? && port.to_i != @output.port
			html_id = "port7_#{@output.id}"
			opt = 7
			update_port = 1
		end

		if !o_type.blank? && @output.o_type != o_type.to_i
			update_items = 1
			get_items

			if o_type.to_i == 2
				@output.update_attributes(:o_type => 2, :port => 1, :bit => 1, :byte => 1)
			else
				@output.update_attributes(:o_type => 1, :port => nil, :bit => nil, :byte =>  nil)
			end
		end

		render :update do |page|
			if update_items == 1
				page.replace_html "output_row_#{@output.id}", :partial => "output_row"
			elsif update_port == 1
				@output.update_attributes(params[:output])
				page.replace_html "#{html_id}", :partial => "shared/port_listbox", :locals => {:show => "link", :opt => opt}
			else
				@output.update_attributes(params[:output])
			end
			page.replace_html "out_msg", "<font style='color:green;'>Eingabe erfolgreich aktualisiert</font>"
		end
	end

	def delete_output
		row = params[:id]
		delete_output_part(row)

		flash[:out_msg] = "<font style='color:green;'>Eingabe erfolgreich entfernt</font>"
		redirect_to "/gpis/ion_entry?tab=output#output#{row.to_i-1}"
	end

	def delete_output_part(row)
		outputs = GpOutput.find(:all, :conditions => ["system_id =? and intnummer >?", @system.id, row.to_i], :select => "id, intnummer")

		row_output = GpOutput.find_by_intnummer_and_system_id(row, @system.id)
		row_output.destroy

		outputs.each do |n|
			current_output = GpOutput.find_by_intnummer_and_system_id(n.intnummer, @system.id, :select => "id, intnummer")
			current_output.update_attributes(:intnummer => n.intnummer-1)
		end
	end
# ---------------------------------------------------

# ------------------ Logic Section -------------------
# ----------------------------------------------------------

	def get_functions
		functions = params[:val].split(";")
		str = ""
		functions.each do |f|
			str += f
			str += "<br />"
		end
		render :update do |page|
			page.replace_html "result", str
		end
	end

	def clean_content
		if !params[:upload].nil?
			if !params[:upload]['datafile'].blank?
				@file_name = params[:upload]['datafile'].original_filename
				post = Datafile.save(params[:upload])
				# Clean original file content
				@calc.clean_file(@file_name)

				@file_name = "gpio.txt"
				@conf_file_name = "gpio.conf"
				import_txt
			end
		end
	end

	def import_txt

		digits = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
		keywords = ["IF", "ELSE", "FUNCTION", "if", "else", "function", "If", "Else", "Function"]
		symbols = ["(", ")", "==", "=", ",", "!"]
		operators = ["&", "|", "~", "^", "<<", ">>"]
		named_operators = ["AND", "XOR", "OR", "NOT", "and", "or", "not", "xor"]
		defines = ["NODE", "Node", "node", "GROUP", "Group", "group"]
		nodes = []
		groups = []
		node_functions = {}
		message = ""
	        action_terms = []
		# get collection of defined Inputs, Outputs, Input signals, Output signals
		word_collection  = @calc.get_word_collection

		# Open clean file for operations
		f = File.open("#{RAILS_ROOT}/conf/clean.txt", 'r')

		# Fetch all terms
		terms = f.read.split(";")
		terms.each do |t|
      a = t
			# remove blank spaces & \t [tabs]

	  	t = t.strip.delete("\t")

			# Separate lines of a term
			term_lines = t.split("\n")



			if term_lines.size == 1
				# ----- single line term -----

				# Check for Group or Node definition
				term_lines[0] = term_lines[0].replace_with_space(defines)
				if @calc.is_node(term_lines[0])
					nodes += @calc.collect_nodes(term_lines[0])
				elsif @calc.is_group(term_lines[0])
					groups += @calc.collect_groups(term_lines[0])
				end

				# line
				content = term_lines[0]
				# check ( ) pairs
				if !content.nil? && content.scan("(").size != content.scan(")").size
					# Error on Line
					message += "Error :: <b> missing ' ( ' or ' ) ' </b> :: at Line #{@calc.line_no(content)} - #{@calc.line_content(content)}  <br />"
				elsif content.scan("==").size != 0
					# Error on Line
					message += "Error :: <b>  wrong use of == </b> :: at Line #{@calc.line_no(content)} - #{@calc.line_content(content)}   <br />"
				else
					content.replace_with_space(symbols + defines)
					words = content.split(" ").delete_all(symbols + digits)
					words -= words.shift.to_a
					#render :text => word_collection.inspect and return false
					# Check availability of a word
					not_found = (word_collection + keywords + operators + named_operators + defines + nodes + groups).not_include(words) if words
					message += "Error :: <b> [ #{not_found.join(', ')} ] Not Found </b> :: at Line #{@calc.line_no(content)} - #{@calc.line_content(content)}  <br />" if !not_found.nil? && !not_found.blank?
				end
			else
				# ----- multi line term -----


				if !term_lines[0].nil? && term_lines[0].scan("=").size != 0
					# Error in block
						message += "Error :: <b> missing ' ; ' </b> :: at Line #{@calc.line_no(term_lines[0])} - #{@calc.line_content(term_lines[0])}  <br />"
				else


					# check pair of {}
					term_str = term_lines.join(" ")
					if term_str.scan("{").size != term_str.scan("}").size
						# Error in block
						message += "Error :: <b> missing ' { ' or ' } ' </b> :: at Line #{@calc.line_no(term_lines[0])} - #{@calc.line_content(term_lines[0])}  <br />"
					else
						term_lines.each do |l|

							# ignore Function keyword, {, }
							if !l.downcase.scan_all(["function", "{", "}"])
								# line
								content = l

								if !content.nil? && !content.blank?
									# Check for pair of ( )
									if content.scan("(").size != content.scan(")").size
										# Error on Line
										message += "Error :: <b> missing ' ( ' or ' ) ' </b> :: at Line #{@calc.line_no(content)} - #{@calc.line_content(content)} <br />"
									else
										# Line may contain IF or expression
										if content.scan_all(keywords)
											# Line with IF / ELSE
											if content.scan("=").size % 2 != 0 || content.downcase.scan("elseif").size == 1
												# Error on Line
												message += "Error :: <b> wrong use of = </b> :: at Line #{@calc.line_no(content)} - #{@calc.line_content(content)}  <br />"
											else
												# get the words apart from KEYWORDS, SYMBOLS & DIGITS
												content.replace_with_space(keywords + symbols)
												words = content.split(" ").delete_all(keywords + symbols + digits)
												words -= words.shift.to_a
                          if @calc.allowed?(words)
                            words.each{|x| word_collection << x}
                          end
												# Check availability of a word
												not_found = (word_collection + keywords + operators + named_operators + defines + nodes + groups).not_include(words) if words
												message += "Error :: <b> [ #{not_found.join(', ')} ] Not Found </b> :: at Line #{@calc.line_no(content)} - #{@calc.line_content(content)}  <br />" if !not_found.nil? && !not_found.blank?
											end
										else
											# Expression
											if content.scan("==").size != 0
												# Error on Line
												message += "Error :: <b>  wrong use of == </b> :: at Line #{@calc.line_no(content)} - #{@calc.line_content(content)}   <br />"
											else
												content.replace_with_space(symbols + defines)
												words = content.split(" ").delete_all(symbols + digits)
												words -= words.shift.to_a
                          if @calc.allowed?(words)
                            words.each{|x| word_collection << x}
                          end
												# Check availability of a word
												not_found = (word_collection + keywords + operators + named_operators + defines + nodes + groups).not_include(words) if words
												message += "Error :: <b> [ #{not_found.join(', ')} ] Not Found </b> :: at Line #{@calc.line_no(content)} - #{@calc.line_content(content)}  <br />" if !not_found.nil? && !not_found.blank?
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
		f.close

		# Remove clean file
		# File.delete("conf/clean.txt")

		if message != ""
			@message = message+"<br /><br />Press BACK to upload other file."
		else
			@singles = []

			direct = 0
			# all terms

			terms.each_with_index do |t,t_index|
				# remove blank spaces & \t [tabs]
				t = t.strip.delete("\t")

				# Separate lines of a term
				term_lines = t.split("\n")

				if term_lines.size == 1
					# Single line function
					term_lines[0] = term_lines[0].replace_with_space(defines)

					if !@calc.is_node(term_lines[0]) && !@calc.is_group(term_lines[0])
						# Tally_CCU_1=Tally_1;
						# BD_1_1_help=((PK1Z1 AND !PK1Z2) OR (PK2Z1 AND !PK2Z2) OR (PK3Z1 AND !PK3Z2) OR (PK4Z1 AND !PK4Z2));


						if nodes.include?(term_lines[0].split("=")[0].split(" ")[1])
							node_functions[term_lines[0].split("=")[0].split(" ")[1]] = term_lines[0].split("=")[1]
						end

						begin
							output = @calc.get_output_value(term_lines[0].split("=")[0].strip)
						rescue NoMethodError
							    message += "Error :: <b>  No outputs found </b> :: at Line #{@calc.line_no(term_lines[0])} - #{@calc.line_content(term_lines[0])}   <br />"
						end
#					  begin
#						  	@calc.get_input_value(term_lines[0].split("=")[1].replace_with_space(symbols + operators).split(" ").delete_all(symbols + operators + named_operators))
#						rescue
#						  	render :text => (term_lines[0].split("=")[1].replace_with_space(symbols + operators).split(" ").delete_all(symbols + operators + named_operators)).inspect and return false
#						end
	  					inputs = @calc.get_input_value(term_lines[0].split("=")[1].replace_with_space(symbols + operators).split(" ").delete_all(symbols + operators + named_operators))
						if inputs.size == 1
							# >>> Direct entry in ibt.conf
							@singles += ["LOGIC_#{@calc.formatnumber3(direct+=1)}=#{output},#{inputs}"]
						elsif inputs.size > 8
							# Error on line
							message += "Error :: <b>  more than 8 inputs </b> :: at Line #{@calc.line_no(term_lines[0])} - #{@calc.line_content(term_lines[0])}   <br />"
						else
							(8-(inputs.size)).times do
								inputs << nil
							end
							InOutTable.add_last(@system.id, output, inputs, @calc.line_content(term_lines[0]).join(" "), @calc.get_boolean_expr(@calc.line_content(term_lines[0]).join(" ")))
						end
					end

				else
					# Multi line function
					inputs = []
					output = []
					term = ""
					line = term_lines[0]

					term_lines.each_with_index do |l, ind|
						term += (@calc.line_content(l).join(" ") + " \n")
						if !l.blank? && !l.downcase.scan_all(["function", "{", "}"])
							if l.scan_all(keywords)

								# Line with IF / ELSE
								# get the words apart from KEYWORDS, SYMBOLS & DIGITS
								l.replace_with_space(keywords + symbols)

								words = l.split(" ").delete_all(keywords + symbols + digits + operators + named_operators)
								words -= words.shift.to_a
								words.each do |w|
									if nodes.include?(w)
										if !node_functions.keys.include?(w)
											message += "Error :: <b>  node #{w} is used </b> :: at Line #{l.split(" ")[0]} but not defined by logic <br />"
										end
									end
								end
								inputs += @calc.get_input_value(words)

							else
								# Expression
							  output += @calc.get_output_value(l.split("=")[0].strip).to_a
  							expr = l.split("=")[1]

								if !@calc.is_number(expr)
									expr.replace_with_space(keywords + symbols)
									words = expr.split(" ").delete_all(keywords + symbols + digits + operators + named_operators)
									words -= words.shift.to_a
									inputs += @calc.get_input_value(words)
								end

							end
						end

					end



					inputs = inputs.uniq
					output = output.uniq

#					render :text => terms.map{|x| terms.index(x).to_s+" : "+x+"<br/>"}.join("<br/>") and return false

					if inputs.size > 8
						# Error on line
						message += "Error :: <b>  more than 8 inputs </b> :: at Line #{@calc.line_no(term_lines[0])} - #{@calc.line_content(term_lines[0])}   <br />"
					elsif (output.blank? || inputs.blank?)
						# Error on line
						message += "Error :: <b>  Improper structure </b> :: at Line #{line} <br />" if !(output.blank? && inputs.blank?)
					else
						# Create temporary Boolean expression to Create temporary Truth Table
						# temporary Truth Table will provide set of values for Inputs
						# to perform calculations
						if term.match(/Connect\:\d*\:\d*/) && term.match(/(Crosspoint+:+\d+:+\d*)/)
              action_terms << term
              InOutTable.add_action_term(@system.id, term)
						else
						  temp_boolean_expr = @calc.get_boolean_expr_beta(term)
						  # if No. of Inputs < 8, set rest of Inputs to '0'
						  (8-(inputs.size)).times do
							  inputs << nil
						  end

						  InOutTable.add_last(@system.id, output[0], inputs, term, temp_boolean_expr)
						end


					end

				end
			end




			@tt_count = InOutTable.get_tables(@system.id).size
            @action_functions = InOutTable.get_action_functions(@system.id)
			if message != ""
				@message = message+"<br />"
			else
				@message = "No Syntax Errors found <br />"

				f = File.open("#{RAILS_ROOT}/conf/"+@system.id.to_s+"/gpio.conf", 'w')
                f.write(';DEF_GPIO_IN_NrofInput="16charName      ",Type,Unit/Panel,Port,Byte,Bit,Invert,RadioButton Group,"16charComment   "'+"\n")

                table_inputs = GpInput.get_inputs(@system.id)
        		table_outputs = GpOutput.get_outputs(@system.id)
                i_types = {'1' => "Unit", '2' => "Panel"}
        		table_inputs.each_with_index do |x,index|
        		    index = index + 1
        		    f.write('DEF_GPIO_IN_' + formatnumber4(index) + '=' + formatstr(x.name) + ',' + (x.i_type.to_s) + ',' + (x.unit.nil? ? '0' : x.unit.to_s) + ',' + (x.port.nil? ? "0" : x.port.to_s) + ',' + (x.byte.nil? ? "0" : x.byte.to_s) + ',' + (x.bit.nil? ? "0" : x.bit.to_s) + ',' + (x.invert.nil? ? "0" : x.invert.to_s) + ',' + (x.radio.nil? ? "0" : x.radio.to_s) + ',' + formatstr(x.comment) + "\n")
    		    end
    		    f.write("\n\n")
                f.write(';DEF_GPIO_OUT_Nrofoutput="16char Name     ","16cha ActiveName",16cha Inact Name",Mode,Type,Unit/Panel,Port,Byte,Bit,Invert,Comment'+"\n")
                table_outputs.each_with_index do |x,index|
                    index = index + 1
                    f.write('DEF_GPIO_OUT_' + formatnumber4(index) + '=' + formatstr(x.name) + ',' + formatstr(x.active_name) + ',' + formatstr(x.inactive_name) + ',' + (x.mode.nil? ? "0" : x.mode.to_s) + ',' + (x.o_type.nil? ? "0" : x.o_type.to_s)+ ',' + (x.unit.nil? ? "0" : x.unit.to_s)+ ',' + (x.port.nil? ? "0" : x.port.to_s) + ',' + (x.byte.nil? ? "0" : x.byte.to_s) + ',' + (x.bit.nil? ? "0" : x.bit.to_s) + ',' + (x.invert.nil? ? "0" : x.invert.to_s) + ',' + formatstr(x.comment) + "\n")
                end
    		    f.write("\n\n")
				# Entry of Direct Terms in ibt.conf
				f.write(";LOGIC_Nr=Output_ID,Input_ID \n\n")
				@singles.each do |s|
					f.write("#{s} \n")
				end
				f.write("\n\n")

				# Entry of Truth Tables in ibt.conf
				@tt_count%8==0 ?  cnt = (@tt_count/8).to_i : cnt = (@tt_count/8).to_i + 1
					@exprs = InOutTable.get_exprs(@system.id)
					b_exprs = Array.new
					@exprs.collect(&:boolean_expr).each_with_index{|x,index| b_exprs[index] = x}
					@boolean_exprs = []
					b_exprs.each_slice(8) {|x|@boolean_exprs << x }

				table = 0
				ibt_table = 0

				cnt.times do
					output_bits = Array.new(8,sprintf("%04d",0))
					ibt_table += 1

					f.write(";Table #{ibt_table} Input definitions \n")
					f.write(";Table Nr=Inputset for output Nr,Input ID,Input ID,Input ID,Input ID,Input ID,Input ID,Input ID,Input ID \n\n")

					# input definitions of truth tables
					counter = 0
					8.times do
						io_table = InOutTable.get_table(table+=1, @system.id)
						input_bits = []
						if io_table
							f.write(";input set Function_#{table} \n")
							input_bits << (io_table.input1 || sprintf("%04d",0000) ) << (io_table.input2 || sprintf("%04d",0000) ) << (io_table.input3 || sprintf("%04d",0000)) << (io_table.input4 || sprintf("%04d",0000)) << (io_table.input5 || sprintf("%04d",0000)) << (io_table.input6  || sprintf("%04d",0000)) << (io_table.input7 || sprintf("%04d",0000)) << (io_table.input8 || sprintf("%04d",0000) )
							f.write("TABLE_DEF_IN_#{@calc.formatnumber3(ibt_table)}=#{@calc.formatnumber2(io_table.intnummer)},#{input_bits.compact.join(',')} \n")
							output_bits[counter] = io_table.output
						end
						counter += 1
					end

					# output definitions of truth tables
					f.write("\n")
					f.write(";Table #{ibt_table} output definitions \n")
					f.write(";Table Nr=Output_ID_Bit1,Output_ID_Bit2,Output_ID_Bit3,Output_ID_Bit4,Output_ID_Bit5,Output_ID_Bit6,Output_ID_Bit7,Output_ID_Bit8 \n\n")
					f.write("TABLE_DEF_OUT_#{@calc.formatnumber3(ibt_table)}=#{output_bits.compact.join(',')} \n\n\n")
					f.write(";Table #{ibt_table} Values \n")

					#==========================================
					# => Boolean Logic
					#==========================================

						# =>  Buffer for Resultbyte (Resultbits for Function 1-8) This are the values in TT ibt.conf
						result_Byte_F_1to8 = Array.new(256,0)

						# =>  Buffer for one result bit for calculation
						preresult_bit = 0

						# =>  Buffer for table Number
						tableNr = 1 		# =>  Generate Table 1 with resultbits from Function 1-8

						# =>  Buffer Tableadress
						tableadress = 0 	# =>  Start with adress 0 for input vector a-h = 00

						kount=0
						256.times do
							result_Byte_F_1to8[kount]=0
						end

						# =>  Calculate TT
						f.write("TABLE_VALUE_#{sprintf('%03d',tableNr)}_#{sprintf('%03d',tableadress)}=")
						256.times do
							if (kount==32) || (kount==64) || (kount==96) || (kount==128) || (kount==160) || (kount==192) || (kount==224)
								f.write("\nTABLE_VALUE_#{sprintf('%03d',tableNr)}_#{sprintf('%03d',tableadress)}=")
							end

							function_nr = 0
							8.times do
								# => count_Bit0=a, count_Bit1=b, count_Bit2=c, count_Bit3=d,
								# => count_Bit4=e, count_Bit5=e, count_Bit6=g, count_Bit7=h

								# => calculate resultbit for given input vektor

								preresult_bit=parse_boolean_expr(@boolean_exprs[ibt_table-1],function_nr,kount)

								# => Rotate Resultbit into the right Function Bitposition to generate Result Byte Functions 1-8  <<function_nr
								result_Byte_F_1to8[kount]= ( (result_Byte_F_1to8[kount] ) | ( preresult_bit << function_nr ))
								function_nr += 1
							end

							tableadress+= 1	# => increment Tableadress
							if (kount==31) || (kount==63) || (kount==95) || (kount==127) || (kount==159) || (kount==191) || (kount==223)
								f.write sprintf("%02x",result_Byte_F_1to8[kount] )
							elsif kount== 255
								f.write sprintf("%02x",result_Byte_F_1to8[kount] )
							else
								f.write sprintf("%02x,",result_Byte_F_1to8[kount] )
							end

							kount+=1
						end
						f.write("\n")
						f.write("\n")
				end

				if @action_functions.length > 0
				  f.write(";ACTION_Nr=Type(1=connect another crosspoint)KvNr,Senke,Compare_Quelle,KvNr,Senke,Quelle\n")
				  @action_functions.each_with_index do |x,index|
				    af_values = x.action_term.scan(/(\d+)/).flatten
				    x.update_attribute('action_term_output',af_values.join(','))
            f.write("ACTION_00#{index}=01,#{af_values.join(',')}\n")
				  end
				end
				f.close
			end

		end

		@exprs = InOutTable.get_exprs(@system.id)
		success = true
		@exprs.each do |x|
				if x.update_attribute("boolean_expr",x.boolean_expr)
					success = true
				else
					success = false
				end
		end
#		@exprs.each { |x| x.update_attribute("boolean_expr",x.boolean_expr) }

#   	render :text => InOutTable.get_exprs(@system.id).map{|y| (y.boolean_expr.inspect+" :<br/> "+y.function)+"\n" }.join("<br/><br/>") and return false

	end



	def parse_boolean_expr(functions,function_nr,kount)


		#	resultbit;

			a=((kount & 0x01)>>0)
			a = ((a == 0) ? false : true)
			b=((kount & 0x02)>>1)
			b = ((b == 0) ? false : true)
			c=((kount & 0x04)>>2)
			c = ((c == 0) ? false : true)
			d=((kount & 0x08)>>3)
			d = ((d == 0) ? false : true)
			e=((kount & 0x10)>>4)
			e = ((e == 0) ? false : true)
			f=((kount & 0x20)>>5)
			f = ((f == 0) ? false : true)
			g=((kount & 0x40)>>6)
			g = ((g == 0) ? false : true)
			h=((kount & 0x80)>>7)
			h = ((h == 0) ? false : true)
			resultbit=0



				if functions[function_nr]
					resultbit = Kernel.eval(functions[function_nr])
				else
					resultbit = false
				end
				return (resultbit ? 1 : 0)
	end


	def parse_boolean_expr_for_tt(function)

			kount = 0
			fun_res = []#
		#	resultbit;
			256.times do
				a=((kount & 0x01)>>0)
				a = ((a == 0) ? false : true)
				b=((kount & 0x02)>>1)
				b = ((b == 0) ? false : true)
				c=((kount & 0x04)>>2)
				c = ((c == 0) ? false : true)
				d=((kount & 0x08)>>3)
				d = ((d == 0) ? false : true)
				e=((kount & 0x10)>>4)
				e = ((e == 0) ? false : true)
				f=((kount & 0x20)>>5)
				f = ((f == 0) ? false : true)
				g=((kount & 0x40)>>6)
				g = ((g == 0) ? false : true)
				h=((kount & 0x80)>>7)
				h = ((h == 0) ? false : true)


				resultbit = Kernel.eval(function)
				fun_res << {:values => [a,b,c,d,e,f,g,h].map{|x| x = (x ? 1 : 0)}, :result => (resultbit ? 1 : 0)}
				kount += 1
			end
			return fun_res
	end

	def gpio_result_print
		@system = System.find(cookies[:system_id])
		@f = File.open("#{RAILS_ROOT}/conf/"+@system.id.to_s+"/gpio.txt", 'r')
		render :layout => false
	end

	def save_truth_table


		@system = System.find(cookies[:system_id])

		table = InOutTable.get_table(params[:id], @system.id)

		if table.function.downcase.scan("function").length == 0
			table.update_attributes(:tt_val => params[:tt_val])
		else
			# Multi line term Truth Table
			# Build Boolean Expression of Conditional Expression
			@calc = Expression.new(@system.id)
			function_out = @calc.get_function_boolean_expr(table.function)

			# function_out[0] = Boolean Expression
			# function_out[1] = Set of Conditional Boolean Expressions
			# function_out[2] = Set of Output Expressions (Not in Boolean form)

			# Calculate Boolean Expression & Generate Truth Table
			tt_val = @calc.generate_truth_table(function_out[1], params[:tt_val], function_out[2])

			# Update Temporary Boolean Expression with Original Boolean Expression
#			table.update_attributes(:boolean_expr => function_out[0], :tt_val => tt_val)
			table.update_attributes(:tt_val => tt_val)
		end

		render :update do |page|

		end
	end

	def list_tables
		@system = System.find(cookies[:system_id])

		#render :text => @tables[0].boolean_expr.inspect and return false
#		@tables = InOutTable.get_truth_tables(@system.id)

		@exprs = InOutTable.get_exprs(@system.id)
#		render :text => @exprs.map{|x| (x.boolean_expr.inspect+" :<br/> "+x.function)+"\n" }.join("<br/><br/>") and return false

		#~ tt = @tables[0].tt_val.split(",")
		#~ tt.delete_at(0)
		#~ tt.delete_at(0)
		#~ tt_vals =  tt.each_slice(8).to_a

		#~ b = tt_vals.map{|x| x.map{|a| a.split(" | ")[0]}}
		#~ b.flatten!
		#~ b = b.map{|x| x.split(" ").join}
		#~ b = b.map{|x| x.to_i(2)}
		#~ render :text => @tables[0].attributes.inspect and return false

		#~ #vals = []
		#~ #b.each do |v|
	#~ #		vals << v.map{|x| x.to_i}.pack('D').unpack('D')
		#~ #end
		#~ render :text => b.inspect and return false
		#render :text => @tables[0].tt_val.split(",")[2].split(" | ").inspect and return false
		render :layout => false
	end
# ----------------------------------------------------------

	def change_items
		@val = params[:val]
		@change_items = 1
		if @val == "Panel"
			@panels = (1..Global::MAX_PANEL).to_a
		elsif @val == "Unit"
			@units = get_units
			@bit = (1..8).to_a
		else
			@change_items = 0
			@bit = (1..8).to_a
		end

		render :update do |page|
			page.replace_html "input_items", :partial => "input_items"
		end
	end

# ------------------ Signals Section -----------------

	def io_signals
		@i_signals = GpInSignal.get_input_signals
		@o_signals = GpOutSignal.get_output_signals
		@options = {"Add Row at last" => 1, "Add N Rows at last" => 2, "Add Row on Position" => 3}

		@gp_in_signal = GpInSignal.new
		@new_out = GpOutSignal.new
	end

# ------------------ Input Signals Section -------------------
# ------------------------------------------------------------
	def options_in_signal
		option = params[:i_signal][:option]
		row = params[:i_signal][:nummer]

		case option
			when '1'
				new_row = GpInSignal.add_last
			when '2'
				new_row = GpInSignal.add_last(row.to_i)
			when '3'
				signals = GpInSignal.find(:all, :conditions => ["intnummer >=?", row.to_i])
				new_row = GpInSignal.add_last
				new_row = row

				row_signal = GpInSignal.find_by_intnummer(row)
				row_signal.update_attributes(:name => nil) if row_signal

				signals.each do |n|
					next_signal = GpInSignal.find_by_intnummer(n.intnummer+1)
					next_signal.update_attributes(:value => n.value+1, :name => n.name)
				end
		end
		redirect_to "/gpis/io_signals?tab=in_signal#in_signal#{new_row}"
	end

	def update_in_signal
		@in_signal = GpInSignal.find(params[:id])
		@in_signal.update_attributes(params[:gp_in_signal])

		render :update do |page|
			page.replace_html "in_msg", "<font style='color:green;'>Eingabe erfolgreich aktualisiert</font>"
		end
	end

	def delete_i_signal
		row = params[:id]
		delete_i_signal_part(row)

		flash[:i_signal_msg] = "<font style='color:green;'>Eingabe erfolgreich entfernt</font>"
		redirect_to "/gpis/io_signals?tab=in_signal#in_signal#{row.to_i-1}"
	end

	def delete_i_signal_part(row)
		signals = GpInSignal.find(:all, :conditions => ["intnummer >?", row.to_i], :select => "id, intnummer")

		row_signal = GpInSignal.find_by_intnummer(row)
		row_signal.destroy

		signals.each do |n|
			current_i_signal = GpInSignal.find_by_intnummer(n.intnummer, :select => "id, intnummer")
			current_i_signal.update_attributes(:intnummer => n.intnummer-1)
		end
	end

# -------------------------------------------------------------


# ------------------ Output Signals Section -------------------
# -------------------------------------------------------------
	def options_out_signal
		option = params[:o_signal][:option]
		row = params[:o_signal][:nummer]

		case option
			when '1'
				new_row = GpOutSignal.add_last
			when '2'
				new_row = GpOutSignal.add_last(row.to_i)
			when '3'
				signals = GpOutSignal.find(:all, :conditions => ["intnummer >=?", row.to_i])
				new_row = GpOutSignal.add_last
				new_row = row

				row_signal = GpOutSignal.find_by_intnummer(row)
				row_signal.update_attributes(:name => nil) if row_signal

				signals.each do |n|
					next_signal = GpOutSignal.find_by_intnummer(n.intnummer+1)
					next_signal.update_attributes(:value => n.value+1, :name => n.name)
				end
		end
		redirect_to "/gpis/io_signals?tab=out_signal#out_signal#{new_row}"
	end

	def update_out_signal
		@out_signal = GpOutSignal.find(params[:id])
		@out_signal.update_attributes(params[:gp_out_signal])

		render :update do |page|
			page.replace_html "out_msg", "<font style='color:green;'>Eingabe erfolgreich aktualisiert</font>"
		end
	end

	def delete_o_signal
		row = params[:id]
		delete_o_signal_part(row)

		flash[:o_signal_msg] = "<font style='color:green;'>Eingabe erfolgreich entfernt</font>"
		redirect_to "/gpis/io_signals?tab=out_signal#out_signal#{row.to_i-1}"
	end

	def delete_o_signal_part(row)
		signals = GpOutSignal.find(:all, :conditions => ["intnummer >?", row.to_i], :select => "id, intnummer")

		row_signal = GpOutSignal.find_by_intnummer(row)
		row_signal.destroy

		signals.each do |n|
			current_o_signal = GpOutSignal.find_by_intnummer(n.intnummer, :select => "id, intnummer")
			current_o_signal.update_attributes(:intnummer => n.intnummer-1)
		end
	end

  def formatnumber4(nbr)
    return "000" + nbr.to_s if nbr.to_i<10
    return "00" + nbr.to_s if nbr.to_i<100
    return "0" + nbr.to_s if nbr.to_i<1000
    return nbr.to_s
  end

  def gpio_monitor
		system_id = cookies[:system_id]
		@frame = Frame.find(params[:id])
		require 'net/telnet'
	    ftpdest = ""
		begin	
			path_var = RAILS_ROOT.gsub("InstantRails-2.0-win/rails_apps/config","")
			File.open("#{path_var}/telnet_batch2/IPs.txt", 'w+') {|f| f.write(@frame.ipadresse) }
			system("cd #{path_var}/telnet_batch2 && start telnet_batch2.exe")
			ftpdest = ftpdest + "<font color='green'><b>Unit (" + @frame.ipadresse + ") monitoring successfully</b></font><br />"
		rescue Timeout::Error => msg
			ftpdest = ftpdest + "<font color='red'>Connection Timeout " + @frame.ipadresse + "&nbsp; <br />" + "</font>"
		rescue Errno::EHOSTUNREACH => msg
			ftpdest = ftpdest + "<font color='red'>Can't connect with host" + @frame.ipadresse + "&nbsp; <br />" + "</font>"
	  	end
		flash[:notice] = ftpdest
		redirect_to :controller => 'systems', :action => "show", :id=>system_id
  end

end

