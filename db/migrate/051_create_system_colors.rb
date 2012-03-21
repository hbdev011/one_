class CreateSystemColors < ActiveRecord::Migration
	def self.up
		create_table :system_colors do |t|
			t.integer :nummer, :length => 11
			t.string :name, :length => 255
			t.string :rgb, :length => 50
			t.timestamps
		end
	end

	def self.down
		drop_table :system_colors
	end
end
