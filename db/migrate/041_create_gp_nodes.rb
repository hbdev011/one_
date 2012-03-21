class CreateGpNodes < ActiveRecord::Migration
  def self.up
	create_table :gp_nodes do |t|
		t.integer :intnummer
    t.integer :system_id
    t.integer :value
		t.string :name
		t.timestamps
	end
  end

  def self.down
    drop_table :gp_nodes
  end
end
