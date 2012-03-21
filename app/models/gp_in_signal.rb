class GpInSignal < ActiveRecord::Base	

	def self.get_input_signals
		return self.find(:all, :select => "id, intnummer, value, name", :order => "intnummer ASC")
	end

	def self.add_last(rows=1)
		last = self.find(:first, :select => "id, intnummer, value", :order => "intnummer DESC")
		last.nil? ? nummer = 0 : nummer = last.intnummer
		nummer == 0 ? val = 4000 : val = last.value

		(1..rows).each do
			self.new(:intnummer => nummer+=1, :value => val+=1).save
		end
		return nummer
	end

	def self.get_input_signals_names
		return self.find(:all, :conditions => ["name IS NOT NULL"], :select => "name", :order => "intnummer ASC")
	end

	def self.get_value(name)
		return self.find_by_name(name, :select => "value")
	end
end
