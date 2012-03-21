class AddColumnToUmds < ActiveRecord::Migration
  def self.up
	add_column :umds, :choice, :string
	add_column :umds, :type_option, :string
	add_column :umds, :ip_address, :string
	add_column :umds, :panel, :integer
	add_column :umds,  :vts_input, :integer
  end

  def self.down
	remove_column :umds, :choice
	remove_column :umds, :type_option
	remove_column :umds, :ip_address
	remove_column :umds, :panel
	remove_column :umds,  :vts_input
  end
end
