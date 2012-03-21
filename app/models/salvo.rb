class Salvo < ActiveRecord::Base
	has_many :crosspoints

	def self.getSalvo(system_id, nummer)
		return self.find_by_system_id_and_intnummer(system_id, nummer)
	end
end
