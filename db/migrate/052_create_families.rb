class CreateFamilies < ActiveRecord::Migration
	def self.up
		create_table :families do |t|
			t.integer :nummer, :length => 11
			t.string :name, :length => 255
			t.integer :system_color_id
			t.timestamps
		end
	end

	def self.down
		drop_table :families
	end
end
