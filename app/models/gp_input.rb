class GpInput < ActiveRecord::Base

	def self.get_inputs(system_id)
		return self.find(:all, :conditions => ["system_id =?", system_id], :order => "intnummer ASC")
	end

	def self.add_last(system_id, rows=1)
		last = self.find(:first, :conditions => ["system_id =?",system_id], :select => "id, intnummer, value", :order => "intnummer DESC")
		last.nil? ? nummer = 0 : nummer = last.intnummer
		nummer == 0 ? val = 1000 : val = last.value

		(1..rows).each do
			self.new(:intnummer => nummer+=1, :value => val+=1, :system_id => system_id, :invert => 0, :radio => 0, :i_type => 1).save
		end
		return nummer
	end

	def self.get_input_names(system_id)
		return self.find(:all, :conditions => ["name IS NOT NULL and system_id =?", system_id], :select => "name", :order => "intnummer ASC")
	end

	def self.get_value(name, system_id)
		return self.find_by_name_and_system_id(name, system_id, :select => "value")
	end

	def self.clear_system_values(system_id)
	    self.find_all_by_system_id(system_id).each{|x| x.destroy}
	end
end

