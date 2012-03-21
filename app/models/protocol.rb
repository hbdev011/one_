class Protocol < ActiveRecord::Base
	has_many :kreuzschienes
	has_many :devices
end
