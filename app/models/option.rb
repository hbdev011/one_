class Option < ActiveRecord::Base
	def self.getTallyOption
		return self.find_by_title("Gehoren Abschnitt Tally")
	end

	def self.getIbtVersionOption
		return self.find_by_title("Versionsnummer ibt datei")
	end

	def self.getIbtContent
		return self.find_by_title("content")
	end

	def self.getNextOption
		return self.find_by_title("next option")
	end

	def self.getSimulateMatrix
		return self.find_by_title("demo_system_simulate_Matrix")
	end

	def self.getMultiViewer
		return self.find_by_title("multiviewer")
	end
end
