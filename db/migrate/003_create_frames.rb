class CreateFrames < ActiveRecord::Migration
  def self.up
    create_table :frames do |t|
        t.column :intnummer, :integer
        t.column :name, :string
        t.column :funktion, :string
        t.column :ipadresse, :string
        t.column :system_id, :integer
        t.timestamps
    end
    
    
    #Frame.new(:name=>'Unit 1' , :funktion=>'Master', :ipadresse=>'192.168.0.10', :system_id=>1).save
    #c = 2 
    #7.times  {
    #  Frame.new(:name=>'Unit ' + c.to_s, :funktion=>'Slave', :ipadresse=>'', :system_id=>1).save
    #  c = c + 1
    #}
    #Frame.new(:name=>'Tally', :funktion=>'TALLY', :ipadresse=>'192.168.0.30', :system_id=>1).save
    
  end

  def self.down
    drop_table :frames
  end
  
end
