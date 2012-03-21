class Device < ActiveRecord::Base
	belongs_to :system
	belongs_to :protocol
end
