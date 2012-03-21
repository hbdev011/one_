class CreateTypetargets < ActiveRecord::Migration
  
  def self.up
    create_table :typetargets do |t|
      t.column :bediengeraet_id, :integer
      t.column :target_id, :integer
      t.column :tasten_id, :integer
      t.timestamps
    end
    
  end

  def self.down
    drop_table :typetargets
  end
end
