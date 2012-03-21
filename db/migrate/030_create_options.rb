class CreateOptions < ActiveRecord::Migration
  def self.up
    create_table :options do |t|
      t.column :title, :string
      t.column :value, :string
      t.timestamps
    end
  end

  def self.down
    drop_table :options
  end
end
