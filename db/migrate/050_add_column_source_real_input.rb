class AddColumnSourceRealInput < ActiveRecord::Migration
  def self.up
	add_column :source, :real_input, :int, :length => 11
  end

  def self.down
	remove_column :source, :real_input
  end
end
