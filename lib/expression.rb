
# Class to perform calculations on terms
#
class Expression

	def initialize(system_id)
		@system = system_id
		@symbols = ["(", ")", "==", "=", ",", "!"]
		@operators = ["&", "|", "~", "^", "<<", ">>"]
		@named_operators = ["AND", "XOR", "OR", "NOT", "and", "or", "not", "xor"]
		@digits = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
		@keywords = ["IF", "ELSE", "FUNCTION", "if", "else", "function", "If", "Else", "Function"]

		@vars = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h']
	end

	# Clean original file
	#
	def clean_file(file_name)
		f = File.open("#{RAILS_ROOT}/conf/"+file_name, 'r')
		c = File.open("#{RAILS_ROOT}/conf/clean.txt", 'w')

		# create separate folder foer each system
		FileUtils.mkdir_p("#{RAILS_ROOT}/conf/"+@system.to_s)
		t = File.open("#{RAILS_ROOT}/conf/"+@system.to_s+"/gpio.txt", 'w')
		cnt = 0

		f.each_line do |line|
			t.write(line)
			line = line.split("//")[0] if line.scan("//").size != 0

			if line.blank?
				cnt+=1
			else
				c.write("#{cnt+=1} #{line} \n")
			end
		end
		c.close
		f.close
		t.close

		# Remove original file
		File.delete("#{RAILS_ROOT}/conf/"+file_name)

	end


	# Returns all the values associated with a Group
	#
	def get_group_vals(group)
		return Group.get_value(group, @system).value.split(",")
	end


	# Returns collection of defined
	# Inputs, Outputs, Input signals, Output signals
	#
	def get_word_collection
		word_collection  = GpInSignal.get_input_signals_names.map {|n| n.name }
		word_collection += GpOutSignal.get_output_signals_names.map {|n| n.name }
		word_collection += GpInput.get_input_names(@system).map {|n| n.name }
		word_collection += GpOutput.get_output_names(@system).map {|n| n.name }
    word_collection << "Crosspoint"
		return word_collection
	end

  def allowed?(words)
    res = false
    if words.length > 0
     words.each do |x|
      if x.match(/^\d*$/) || x.match(/^(Crosspoint+:+\d+:+\d*)$/)
        res = true
      else
        res = false
      end
     end
    elsif
      if words.is_a? String
        if x.match(/^\d*$/) or x.match(/^(Crosspoint+:+\d+:+\d*)$/)
          res = true
        else
          res = false
        end
      end
    end
    return res
  end

	# Returns True if Line defines Node
	#
	def is_node(line)
		return line.split(" ")[1].downcase == "node" ? true : false
	end

	# Returns True if Line defines Group
	#
	def is_group(line)
		return line.split(" ")[1].downcase == "group" ? true : false
	end

	# Returns True if string is number
	#
	def is_number(str)
		if !str.nil? && !str.blank?
			chrs = ('a'..'z').to_a
			chrs << " "
			str.split("").each do |n|
				return false if chrs.include? n
			end
			return true
		else
			return false
		end
	end

	# Returns all Nodes defined in a Line
	#
	def collect_nodes(line)
		GpNode.add_nodes(line.split("#{line.split(' ')[1]}")[1].strip.split(","), @system)
		return line.split("#{line.split(' ')[1]}")[1].strip.split(",")
	end

	# Returns Group defined in a Line
	#
	def collect_groups(line)
		Group.add_group(line.split("#{line.split(' ')[1]}")[1].strip.split("=")[0], line.split("#{line.split(' ')[1]}")[1].strip.split("=")[1], @system)
		return line.split("#{line.split(' ')[1]}")[1].strip.split("=")[0].to_a
	end

	# Returns Line Number
	#
	def line_no(line)
		return line.split(" ")[0]
	end

	# Returns Line Content by removing Line Number
	#
	def line_content(line)
		line = line.split(" ")
		line.delete_at(0)
		return line
	end


	# Returns numeric value of an Output
	#
  def get_output_value(output)
    output = line_content(output).to_s
    if output.match(/^Connect\:\d*\:\d*$/)
      return "testing"
    else
      return (GpOutput.get_value(output, @system) || GpNode.get_value(output, @system) || GpOutSignal.get_value(output) || GpInSignal.get_value(output)).value
    end
  end

	# Returns numeric value of Inputs
	#
	def get_input_value(input)

		values = []

		nums = (0..9).to_a.map{|x| x.to_s}

		input.each do |n|
			gval = Group.get_value(n, @system)
			if !gval.nil? && !gval.blank?
				# vals = gval.value.split(",")
				gval.value.split(",").each do |v|
					values += ((( GpInput.get_value(v, @system) || GpInSignal.get_value(v) ) || GpOutSignal.get_value(v) ) || GpNode.get_value(v, @system)).value.to_a
				end
			elsif nums.include?(n)
				values << n
	    elsif allowed?(n)
				values << n
			else
#				return ( (( GpInput.get_value(n, @system) || GpInSignal.get_value(n) ) || GpOutSignal.get_value(n) ) || GpNode.get_value(n, @system) )
				values += ( (( GpInput.get_value(n, @system) || GpInSignal.get_value(n) ) || GpOutSignal.get_value(n) ) || GpNode.get_value(n, @system) ).value.to_a
			end
		end
		return values
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

	# Create temporary Boolean expression to Create temporary Truth Table
	# temporary Truth Table will provide set of values for Inputs
	# to perform calculations
	#
	def get_temp_boolean_expr(input_count)
		expr = ""
		input_count.times do |c|
			expr += (@vars[c] + "|")
		end
		return expr.slice(0..-2)
	end

	# Convert term to Boolean Expression to generate Truth Table
	#
	def get_boolean_expr(expr, flag=0)
		cnt=-1
		boolean_expr = ""

		expr = expr.replace_with_space(@symbols+@operators-["="])

		expr_arr = expr.split("=")[1]
		(!expr_arr.nil? and !expr_arr.blank?) ? expr_arr = expr_arr.split(" ") : expr_arr = expr.split(" ")

		expr_arr.each_with_index do |e, ind|
			if (@symbols-["!"]).include? e
				boolean_expr += e.strip
			elsif (@operators+@named_operators).include? e
				if ["and", "&"].include? e.downcase
#					(flag == 0) ? boolean_expr += "" : boolean_expr += "&"
					boolean_expr += " & "
				elsif ["or", "|"].include? e.downcase
					boolean_expr += "|"
				elsif ["xor", "^"].include? e.downcase
					boolean_expr += "^"
				end
			elsif e.to_s == "\'"
				boolean_expr += e.to_s
			else
				gval = Group.get_value(e, @system)
				if !gval.nil? && !gval.blank?
					# Replace Group with expression shown below
					# using it 's associated values
					# a + (b*2) + (c*4)
					gexpr = ""
					gval.value.split(",").each_with_index do |v, ind|
						gexpr += (" [" + @vars[cnt+=1] + "*" + (2**ind).to_s + "] +")
					end
					boolean_expr += gexpr.slice(0..-2)

				elsif expr_arr[ind-1] == "!"
					boolean_expr += ("!"+@vars[cnt+=1])
				elsif ["==", "!=", ">", "<", ">=", "<="].include? expr_arr[ind-1].to_s
					boolean_expr += e
				else
					boolean_expr += @vars[cnt+=1] if e != "!"
				end
			end

		end
		return boolean_expr
	end


	# Generate Boolean Expression for
	# term with Function
	#
	def get_function_boolean_expr(expr)
		# Conditions expressions
		cond_expr = []

		# all possible outputs of the Function
		output_expr = []

		# whole Boolean Expression
		boolean_expr = ""

		# Separate lines of a term
		term_lines = expr.split("\n")

		term_lines.each_with_index do |l, ind|

			if !l.blank? && !l.downcase.scan_all(["function", "{", "}"])
				if l.scan_all(@keywords)
					# Line with IF / ELSE
					# save original line expression
					line = l.split(" ").delete_all(@keywords).join(" ")

					# separate Expression from line content
					l.replace_with_space(@keywords + @symbols-["="])
					l = l.split(" ").delete_all(@keywords).join(" ")

					# replace original line expression with boolean expression
					expr = expr.gsub(line, get_boolean_expr(l)) if !l.blank?

					cond_expr << get_boolean_expr(l, 1) if !l.blank?
				else
					output_expr << l if !l.blank?
				end
			end
		end
		return [expr, cond_expr, output_expr]
	end


#################################################################################
# => My Own Boolean Parser
#################################################################################
	def get_boolean_expr_beta(expr)
		cnt=-1
		boolean_expr = ""

		expr = expr.replace_with_space(@symbols+@operators-["="])

		#expr_arr = expr.split("=")[1]
 		#expr_arr = (!expr_arr.nil? and !expr_arr.blank?) ? expr_arr.split(" ") : expr.split(" ")
		expr_arr = expr.split(" ")

		constants = []
		local_vars = []

		expr_arr.each{|x| constants << x if !Group.get_value(x, @system).nil?  }
		expr_arr.each{|x| local_vars << x if x.match(/[a-zA-Z0-9_]+[_]{1}+[a-zA-Z0-9_]*|[a-zA-Z0-9_]/)  }

		local_vars.delete_all(@keywords+@operators+@named_operators)
		constants.uniq!
		local_vars.uniq!

		@constants = {}
		@local_vars = {}
		i = 0
		constants.each do |c|
			@constants[c] = [@vars[i],@vars[i+=1]]
			i+=1
		end
		#j = 0						return gexpr
		local_vars.each do |c|
			@local_vars[c] = @vars[i]
			i+=1
		end

		expr_arr.each_with_index do |e, ind|
				if (@symbols-["!"]).include? e
					boolean_expr += e
				elsif (@operators+@named_operators).include? e
					if ["and", "&"].include? e.downcase
						boolean_expr += " & "
					elsif ["or", "|"].include? e.downcase
						boolean_expr += " | "
					elsif ["xor", "^"].include? e.downcase
						boolean_expr += " ^ "
					end
				elsif e.to_s == "\'"
					boolean_expr += e.to_s
				else
					if ["1","0"].include? e
						boolean_expr += " #{e.to_i == 1 ? true : false} "
					end
					if @constants.keys.include?(e)
						# Replace Group with expression shown below
						# using it 's associated values
						# a + (b*2) + (c*4)
						gexpr = ""

						gval = Group.get_value(e, @system)

						gval.value.split(",").each_with_index do |v, ind|
							if ind%2 != 0
									gexpr += ("!" + @constants[e][1])
							else
									gexpr += (@constants[e][0]+" & ")
							end

						end

						boolean_expr += gexpr#.slice(0..-2)

					elsif @local_vars.keys.include?(e)
							if e.match(/[a-zA-Z0-9_]+[\=]{1}+[\d]/)
								boolean_expr += "\noutput = #{(e.split("=")[1].to_i == 1) ? true : false}"
							elsif e.match(/[a-zA-Z0-9_]+[\=]{1}/)
								boolean_expr += "\noutput ="
							else
								boolean_expr += @local_vars[e].to_s
							end

					elsif expr_arr[ind-1] == "!"
						cnt+=1
						boolean_expr += ("!"+@vars[cnt])

					elsif e.downcase.match(/else|elsif/)
						boolean_expr += "\n" + e + "\n"
					elsif ["1","0"].include? e
						boolean_expr += " " + (e)
					elsif ["(",")","{","function","IF","ELSE IF","ELSE","}","==", "!=", ">", "<", ">=", "<=","1","0"].include? expr_arr[ind-1].to_s.strip

						if e.strip.match(/[a-zA-Z0-9_]+[\=]{1}+[0-1]/)
							output = e.split("=")
							boolean_expr += " output=#{(output[1].to_i == 1) ? true : false}" if e != "!"
						else
							boolean_expr += " "+e.downcase+" "
						end
					else

						if e.strip.match(/[a-zA-Z0-9_]+[\=]{1}+[0-1]/)
							output = e.split("=")
							boolean_expr += "output = #{(output[1].to_i == 1) ? true : false}" if e != "!"
						else
							boolean_expr += e
						end
					end
				end


		end

		boolean_expr = boolean_expr.downcase.gsub(/(else+\s+if)/,'elsif').gsub("function",'').gsub(/[\{,\}]/,'')
		if boolean_expr.strip.match(/^if/)
			boolean_expr += "\nend"
		end

		return boolean_expr
	end


#################################################################################
# => End of my Own Boolean Parser											   #
#################################################################################




	# Generate Truth Table for Function {..} like terms
	#
	def generate_truth_table(cond_expr, tt_val, output_expr)
		new_tt_val = ""
		tt_val.split(",").each_with_index do |v, ind|

			if ind < 2
				new_tt_val += (v.to_s + ", <br />")
			else
				row_val = v.split("|")[0].split(" ")
				ans = calculate_expr(cond_expr, output_expr, row_val)
				new_tt_val += (row_val.join(" ")+" | "+ ans + "<br />")
			end

		end
		return new_tt_val
	end


	# Calculate conditional expressions to get suitable output
	#
	def calculate_expr(cond_expr_arr, output_expr_arr, row_val)
		@cnt1 = -1 # counter for cond_expr
		@expr_arr = cond_expr_arr
		@outputs = output_expr_arr

		return calculate_expr_part(@expr_arr[@cnt1+=1], row_val)

	end


	# A recursive sub function that
	# checks available conditions one by one and returns final output
	#
	def calculate_expr_part(cond_expr, row_val)

		cnt2 = -1 # counter for row_val
		cnt3 = -1 # counter for operators
		boolean_expr = ""

		operators = cond_expr.to_s.scan(/\)(.*?)\(/)

		cond_expr.to_s.scan(/\((.*?)\)/).each do |e|
			e = e.to_s.delete("(").delete(")")

			rel_operator = get_relational(e)
			ls = e.split("#{rel_operator}")[0].scan(/\[(.*?)\]/)
			rs = e.split("#{rel_operator}")[1]

			if ls.size == 0
				if rs.nil?
					# replace vars with val
					# call compute()

					e = e.to_s.replace_with_space(@vars)
					expr_part = ""
					e.split(" ").each do |v|

						(@vars.include? v) ? (expr_part += row_val[cnt2+=1] || '') : ( (v == "&") ? (expr_part += "") : (expr_part += v.to_s) )
					end

					boolean_expr += (compute(expr_part).to_s + operators[cnt3+=1].to_s)
				else
					ls = e.split("#{rel_operator}")[0]
					ls = ls.to_s.replace_with_space(@vars)
					expr_part = ""
					ls.split(" ").each do |v|
						(@vars.include? v) ? expr_part += row_val[cnt2+=1] : (v == "&") ? expr_part += "" : expr_part += v.to_s
					end

					if compare_ls_rs(compute(expr_part), rel_operator, rs)
						boolean_expr += ("1" + operators[cnt3+=1].to_s)
					else
						boolean_expr += ("0" + operators[cnt3+=1].to_s)
					end

				end
			else
				if compare_ls_rs(cal_group_val(row_val[cnt2+1..cnt2+=ls.size]), rel_operator, rs)
					boolean_expr += ("1" + operators[cnt3+=1].to_s)
				else
					boolean_expr += ("0" + operators[cnt3+=1].to_s)
				end
			end
		end

=begin
		if (cond1)
			out 1
		else if (cond2)
			out 2
		else
			out 3
		end
=end
		if compute(boolean_expr) == 1
			# Return output mentioned with cnt1 condition
			return get_output
		else
			# go for next condition
			# call - calculate_expr(cond_expr, row_val)
			if !@expr_arr[@cnt1+=1].nil?
				calculate_expr_part(@expr_arr[@cnt1], row_val)
			else
				# return last output mentioned in ELSE part
				return get_output
			end
		end

	end

	# Returns output value from Output expression
	#
	def get_output
		out = @outputs[@cnt1].to_s.split("=")[1]
		# >>> Calculate Output expression
=begin
		exp = out.to_s.scan(/!\(.*?\).*/).to_s.slice(1..-1) + "\'"  if out.slice(0..1) == "!("

		exp.scan(/!\(.*?\)/).each do |e|
			exp = exp.gsub(e.to_s, (e.to_s.slice(1..-1)+"\'" )  )
		end


=end
		return (out.nil?) ? "0" : out
	end



	# Compare Left & Right side of an expression &
	# Return True / False accordingly
	#
	def compare_ls_rs(ls_val, ope, rs_val)
		case ope
			when "=="
				return (ls_val == rs_val.to_i) ? true : false
			when "!="
				return (ls_val != rs_val.to_i) ? true : false
			when ">="
				return (ls_val >= rs_val.to_i) ? true : false
			when "<="
				return (ls_val <= rs_val.to_i) ? true : false
			when ">"
				return (ls_val > rs_val.to_i) ? true : false
			when "<"
				return (ls_val < rs_val.to_i) ? true : false
		end
	end

	# Trace the relational operator and split expression using it
	#
	def get_relational(expr)
		["==", "!=", ">", "<", ">=", "<="].each do |ope|
			if expr.scan(ope).length == 1
				return ope
			end
		end
	end


	# Calculate value for Group's Boolean expression
	# i.e, a + (b*2)
	#
	def cal_group_val(val_arr)
		val = 0
		val_arr.each_with_index do |v, ind|
			val += v.to_i * 2**ind
		end
		return val
	end

	# Calculate final value of Conditional Expression
	# of term with Function
	#
	def compute(expr)

		j=0;
		while j<=expr.size
	      if !expr[j+1].nil?
				if expr[j+1].chr=='`' || expr[j+1].chr=="'"
					(expr[j].chr=='1') ? k="0" : k="1"
					expr=expr.slice(0,j).to_s+k+expr.slice(j+2..-1).to_s
					#j=j-1
				end
	      end
			j+=1
		end

		j=0
	   while(j<=expr.size)
	      if !expr[j+1].nil?
				if (expr[j].chr=='0' || expr[j].chr=='1') && (expr[j+1].chr=='0' || expr[j+1].chr=='1')
					(expr[j].chr=='1' && expr[j+1].chr=='1') ? k="1" : k="0"
					expr=expr.slice(0,j).to_s+k+expr.slice(j+2..-1).to_s
					#j=j-1;
				elsif (expr[j].chr=='0' || expr[j].chr=='1') && expr[j+1].chr=='^'
					(expr[j].chr==expr[j+2].chr) ? k="0" : k="1"
					expr=expr.slice(0,j).to_s+k+expr.slice(j+3..-1).to_s
					#j=j-1;
				end
	      end
			j+=1
		end
		k=0

		j=0
		while(j<expr.size)
			if expr[j].chr=='1'
				k=1
				return k
			end
			j+=1
		end
		return k

	end

end
