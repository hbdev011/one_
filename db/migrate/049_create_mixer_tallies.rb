class CreateMixerTallies < ActiveRecord::Migration
  def self.up
    create_table :mixer_tallies do |t|
      t.column :intnummer, :integer
      t.column :nummer, :string
      t.column :name, :string
      t.column :kreuzschiene_id, :integer
      t.column :senke_id, :integer
      t.column :system_id, :integer
      t.timestamps
    end
  end

  def self.down
    drop_table :mixer_tallies
  end
end
