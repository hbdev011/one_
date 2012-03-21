class CreateGpOutSignals < ActiveRecord::Migration
  def self.up
	create_table :gp_out_signals do |t|
		t.integer :intnummer
    t.integer :value
		t.string :name
		t.timestamps
	end
  end

  def self.down
    drop_table :gp_out_signals
  end
end
