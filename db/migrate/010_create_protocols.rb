class CreateProtocols < ActiveRecord::Migration
  def self.up
    create_table :protocols do |t|
      t.column :nummer, :integer
      t.column :name, :string
      t.column :type_of_protocol, :string
      t.timestamps
    end

    Protocol.new(:nummer=>1,  :name=>"Pro-Bel").save
    Protocol.new(:nummer=>2,  :name=>"IBT-BD").save
    Protocol.new(:nummer=>3,  :name=>"Res  3").save
    Protocol.new(:nummer=>4,  :name=>"MPK   ").save
    Protocol.new(:nummer=>5,  :name=>"ACOS  ").save
    Protocol.new(:nummer=>6,  :name=>"NCB   ").save
    Protocol.new(:nummer=>7,  :name=>"Res  6").save
    Protocol.new(:nummer=>8,  :name=>"Res  7").save
    Protocol.new(:nummer=>9,  :name=>"Res  8").save
    Protocol.new(:nummer=>10, :name=>"Res  9").save
    Protocol.new(:nummer=>11, :name=>"Res 10").save
    Protocol.new(:nummer=>12, :name=>"Res 11").save
    Protocol.new(:nummer=>13, :name=>"Res 12").save
    Protocol.new(:nummer=>14, :name=>"AZ-1  ").save
    Protocol.new(:nummer=>15, :name=>"TSL   ").save
    Protocol.new(:nummer=>16, :name=>"IBT-UMD").save

  end

  def self.down
    drop_table :protocols
  end
end
