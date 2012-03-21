class CreateTargets < ActiveRecord::Migration
  def self.up
    create_table :targets, :options => "auto_increment = 0" do |t|
      t.column :intnummer, :integer

      t.column :nummer, :integer
      t.column :name5stellig, :string
      t.column :name4stellig, :string
      t.column :kreuzschiene_id, :integer
      t.column :bediengeraet_id, :integer
      t.timestamps
    end
  
    
  end

  def self.down
    drop_table :targets
  end
end
