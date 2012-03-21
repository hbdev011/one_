class CreateTypesources < ActiveRecord::Migration
  def self.up
    create_table :typesources do |t|
      t.column :bediengeraet_id, :integer
      t.column :source_id, :integer
      t.column :tasten_id, :integer
      t.column :sourcetype, :string
      t.timestamps
    end
  end

  def self.down
    drop_table :typesources
  end
end
