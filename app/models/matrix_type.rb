class MatrixType < ActiveRecord::Base
	has_many :kreuzschienes

	def self.getMatrixTypes
		return self.find(:all, :select => "intnummer, title", :order => "intnummer")
	end

end
