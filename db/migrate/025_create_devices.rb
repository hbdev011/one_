class CreateDevices < ActiveRecord::Migration
  def self.up
    create_table :devices do |t|
      t.column :intnummer, :integer
      t.column :nummer, :string
      t.column :name, :string
      t.column :protocol_id, :integer
      t.column :unit, :integer
      t.column :port, :integer
      t.column :ip, :string
      t.column :system_id, :integer
      t.timestamps
    end
  end

  def self.down
    drop_table :devices
  end
end
