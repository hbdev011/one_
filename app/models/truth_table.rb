class TruthTable < ActiveRecord::Base
	def self.get_truth_tables(system_id)
		return self.find(:all, :conditions => ["system_id =?", system_id], :order => "intnummer ASC")
	end

	def self.add_last(system_id, output, inputs)
		last = self.find(:first, :conditions => ["system_id =?",system_id], :select => "id, intnummer", :order => "intnummer DESC")
		last.nil? ? nummer = 0 : nummer = last.intnummer

		self.new(:intnummer => nummer+=1, :system_id => system_id, :output => output, :input1 => inputs[0], :input2 => inputs[1], :input3 => inputs[2], :input4 => inputs[3], :input5 => inputs[4], :input6 => inputs[5], :input7 => inputs[6], :input8 => inputs[7]).save
	end
 
	def self.get_truth_table(intnummer, system_id)
		return self.find_by_intnummer_and_system_id(intnummer, system_id)
	end 
 
end
