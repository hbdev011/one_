class AddSourceIdColumnToUmds < ActiveRecord::Migration
	def self.up
		add_column :umds, :source_id, :integer
	end

	def self.down
		remove_column :umds, :source_id
	end
end
