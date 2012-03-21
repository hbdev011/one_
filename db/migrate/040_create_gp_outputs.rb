class CreateGpOutputs < ActiveRecord::Migration
  def self.up
	create_table :gp_outputs do |t|
		t.integer :intnummer
		t.integer :value
		t.integer :mode, :limit => 1
		t.string :name
		t.string :active_name
		t.string :inactive_name
		t.integer :system_id
		t.integer :unit
		t.integer :port
		t.integer :byte
		t.integer :bit
		t.integer :invert, :limit => 2
		t.integer :o_type, :limit => 1
		t.string :comment, :length => 16
		t.timestamps
	end
  end

  def self.down
    drop_table :gp_outputs
  end
end
