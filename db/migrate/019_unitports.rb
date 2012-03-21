class Unitports < ActiveRecord::Migration
  def self.up
    add_column :kreuzschienes, :unit2, :string
    add_column :kreuzschienes, :port2, :string
    
  end

  def self.down
  end
end
