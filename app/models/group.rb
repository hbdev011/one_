class Group < ActiveRecord::Base

	def self.get_groups(system_id)
		return self.find(:all, :conditions => ["system_id =?", system_id], :order => "intnummer ASC")
	end

	def self.add_group(name, value, system_id)
		last = self.find(:first, :conditions => ["system_id =?", system_id], :select => "id, intnummer", :order => "intnummer DESC")
		last.nil? ? nummer = 0 : nummer = last.intnummer

		self.new(:intnummer => nummer+=1, :name => name.to_s, :value => value.to_s, :system_id => system_id).save
	end

	def self.get_value(name, system_id)
		return self.find_by_name_and_system_id(name, system_id, :select => "value")
	end
end
