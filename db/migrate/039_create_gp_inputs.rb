class CreateGpInputs < ActiveRecord::Migration
  def self.up
	create_table :gp_inputs do |t|
		t.integer :intnummer
		t.integer :value
		t.string :name
		t.integer :system_id
		t.integer :unit
		t.integer :port
		t.integer :byte
		t.integer :bit
		t.integer :invert, :limit => 2
		t.integer :radio, :limit => 2
		t.integer :i_type, :limit => 1
		t.string :comment, :length => 16
		t.timestamps
	end
  end

  def self.down
	drop_table :gp_inputs
  end
end
