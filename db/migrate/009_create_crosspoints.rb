class CreateCrosspoints < ActiveRecord::Migration
  def self.up
    create_table :crosspoints do |t|
      t.column :nummer, :integer
      t.column :salvo_id, :integer
      t.column :kreuzschiene_id, :integer
      t.column :source_id, :integer
      t.column :target_id, :integer
      t.column :system_id, :integer
      t.timestamps
    end
  end

  def self.down
    drop_table :crosspoints
  end
end
