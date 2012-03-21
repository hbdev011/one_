class CreateSalvos < ActiveRecord::Migration
  def self.up
    create_table :salvos do |t|
      t.column :intnummer, :integer
      t.column :name, :string
      t.column :system_id, :integer
      t.timestamps
    end
  end

  def self.down
    drop_table :salvos
  end
end
