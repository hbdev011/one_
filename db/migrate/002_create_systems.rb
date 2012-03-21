class CreateSystems < ActiveRecord::Migration
  def self.up
    create_table :systems do |t|
        t.column :name, :string
        t.column :version, :integer
        
        t.timestamps
    end
    
    System.new(:name=>"DVKS_100", :version=>1).save
  end

  def self.down
    drop_table :systems
  end
end
