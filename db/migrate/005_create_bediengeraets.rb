class CreateBediengeraets < ActiveRecord::Migration
  def self.up
    create_table :bediengeraets do |t|
      t.column :intnummer, :integer
      t.column :nummer, :string
      t.column :name8stellig, :string
      t.column :name4stellig, :string
      t.column :unit, :integer
      t.column :port, :integer
      t.column :bdtype_id, :integer
      t.column :system_id, :integer
      t.column :normalquellen_kv_id, :integer
      t.column :splitquellen_kv_id, :integer
      t.timestamps
    end
    
  end

  def self.down
    drop_table :bediengeraets
  end
end
