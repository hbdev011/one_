class InOutTable < ActiveRecord::Base

	def self.get_tables(system_id)
		return self.find(:all, :conditions => ["system_id =? AND action_term IS NULL", system_id], :order => "intnummer ASC")
	end

	def self.get_action_functions(system_id)
		return self.find(:all, :conditions => ["system_id =? AND action_term IS NOT NULL", system_id], :order => "intnummer ASC")
	end


	def self.add_last(system_id, output, inputs, function, boolean_expr)
		last = self.find(:first, :conditions => ["system_id =?",system_id], :select => "id, intnummer", :order => "intnummer DESC")
		last.nil? ? nummer = 0 : nummer = last.intnummer

		self.new(:intnummer => nummer+=1, :system_id => system_id, :output => output, :input1 => inputs[0], :input2 => inputs[1], :input3 => inputs[2], :input4 => inputs[3], :input5 => inputs[4], :input6 => inputs[5], :input7 => inputs[6], :input8 => inputs[7], :function => function, :boolean_expr => boolean_expr).save
	end

	def self.add_action_term(system_id, function)
		last = self.find(:first, :conditions => ["system_id =?",system_id], :select => "id, intnummer", :order => "intnummer DESC")
    nummer = (last.nil?) ? 0 : last.intnummer
		self.new(:intnummer => nummer+=1, :system_id => system_id, :action_term => function).save
	end

	def self.get_table(intnummer, system_id)
		return self.find_by_intnummer_and_system_id(intnummer, system_id)
	end

 	def self.get_exprs(system_id)
 		return self.find_all_by_system_id(system_id, :select => "intnummer, function, boolean_expr")
 	end

 	def self.get_truth_tables(system_id)
 		return self.find(:all, :conditions => ["system_id =?", system_id], :select => "intnummer, function, tt_val,boolean_expr", :order => "intnummer ASC")
 	end

 	def self.get_functions(system_id)
 		return self.find(:all, :conditions=>["system_id =? AND function LIKE?", system_id, "%function%"], :select => "intnummer, function, tt_val, boolean_expr")
 	end

end

