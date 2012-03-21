class SignalSenken < ActiveRecord::Base
	has_many :targets

	def self.getSenkenSignals
		return self.find(:all, :select => "intnummer, title", :order => "intnummer ASC")
	end

	def self.getSignalByTitle(title)
		return self.find_by_title(title, :select => "intnummer, title")
	end

end
