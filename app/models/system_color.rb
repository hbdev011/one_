class SystemColor < ActiveRecord::Base
	has_one :family

	def getcolor(id)
		system_color = SystemColor.find_by_nummer(id)
		return system_color
	end
end
