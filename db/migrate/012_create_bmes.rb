class CreateBmes < ActiveRecord::Migration
  def self.up
    create_table :bmes do |t|
      t.column :taste, :integer
      t.column :source_id, :integer
      t.column :system_id, :integer
      t.timestamps
    end
    
  end

  def self.down
    drop_table :bmes
  end
end
