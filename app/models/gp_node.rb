class GpNode < ActiveRecord::Base

	def self.get_nodes(system_id)
		return self.find(:all, :conditions => ["system_id =?", system_id], :order => "intnummer ASC")
	end

	def self.add_nodes(nodes, system_id)
		nodes.each do |n|
			last = self.find(:first, :conditions => ["system_id =?", system_id], :select => "id, intnummer, value", :order => "intnummer DESC")
			last.nil? ? nummer = 0 : nummer = last.intnummer
			nummer == 0 ? val = 3000 : val = last.value

			self.new(:intnummer => nummer+=1, :name => n.to_s, :value => val+=1, :system_id => system_id).save
		end
	end

	def self.get_value(name, system_id)
		return self.find_by_name_and_system_id(name, system_id, :select => "value")
	end
end
