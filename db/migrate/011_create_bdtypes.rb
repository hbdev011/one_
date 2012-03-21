class CreateBdtypes < ActiveRecord::Migration
  def self.up
    create_table :bdtypes do |t|
      t.column :nummer, :integer
      t.column :name, :string

      t.timestamps
    end
    
    Bdtype.new(:nummer=>1, :name=>"T32/unten 1").save
    Bdtype.new(:nummer=>2, :name=>"48+3 T/K ZDF").save
    Bdtype.new(:nummer=>3, :name=>"48+3 YX ZDF").save
    Bdtype.new(:nummer=>4, :name=>"OCP        ").save
    Bdtype.new(:nummer=>5, :name=>"48+3 XY WDR").save
    
  end

  def self.down
    drop_table :bdtypes
  end
end
