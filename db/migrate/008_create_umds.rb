class CreateUmds < ActiveRecord::Migration
  def self.up
    create_table :umds do |t|
      t.column :intnummer, :integer
      t.column :umdnummer, :string
      t.column :kreuzschiene_id, :integer
      t.column :target_id, :integer
      t.column :festtext, :string
      t.column :monitor, :string
      t.column :gpi, :string
      t.column :bme, :string
      t.column :mon_havarie, :string
      t.column :konfiguration, :string
      t.column :system_id, :integer
      t.timestamps
    end


  end

  def self.down
    drop_table :umds
  end
end
