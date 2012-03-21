class CreateSignalQuellens < ActiveRecord::Migration
  def self.up
    create_table :signal_quellens do |t|
      t.integer :intnummer
      t.string :title, :length => 3
      t.string :hexa, :length => 10	
      t.timestamps
    end

    SignalQuellen.new(:intnummer=>1,   :title=>"ISD", :hexa => "0x00").save
    SignalQuellen.new(:intnummer=>2,   :title=>"OUT", :hexa => "0x01").save
    SignalQuellen.new(:intnummer=>3,   :title=>"LST", :hexa => "0x02").save
    SignalQuellen.new(:intnummer=>4,   :title=>"MIC", :hexa => "0x10").save
    SignalQuellen.new(:intnummer=>5,   :title=>"TBK", :hexa => "").save
    SignalQuellen.new(:intnummer=>6,   :title=>"MTR", :hexa => "").save
    SignalQuellen.new(:intnummer=>7,   :title=>"HDR", :hexa => "").save
    SignalQuellen.new(:intnummer=>8,   :title=>"VTR", :hexa => "").save
    SignalQuellen.new(:intnummer=>9,   :title=>"OCR", :hexa => "").save
    SignalQuellen.new(:intnummer=>10,  :title=>"RXR", :hexa => "").save
    SignalQuellen.new(:intnummer=>11,  :title=>"ATR", :hexa => "").save
    SignalQuellen.new(:intnummer=>12,  :title=>"CCR", :hexa => "").save
    SignalQuellen.new(:intnummer=>13,  :title=>"DTR", :hexa => "").save
    SignalQuellen.new(:intnummer=>14,  :title=>"RDR", :hexa => "").save
    SignalQuellen.new(:intnummer=>15,  :title=>"CDR", :hexa => "").save
    SignalQuellen.new(:intnummer=>16,  :title=>"PLR", :hexa => "").save
    SignalQuellen.new(:intnummer=>17,  :title=>"CPR", :hexa => "").save
    SignalQuellen.new(:intnummer=>18,  :title=>"B0R", :hexa => "").save
    SignalQuellen.new(:intnummer=>19,  :title=>"B1R", :hexa => "").save
    SignalQuellen.new(:intnummer=>20,  :title=>"B2R", :hexa => "").save
    SignalQuellen.new(:intnummer=>21,  :title=>"B3R", :hexa => "").save
    SignalQuellen.new(:intnummer=>22,  :title=>"B4R", :hexa => "").save
    SignalQuellen.new(:intnummer=>23,  :title=>"B5R", :hexa => "").save
    SignalQuellen.new(:intnummer=>24,  :title=>"B6R", :hexa => "").save
    SignalQuellen.new(:intnummer=>25,  :title=>"B7R", :hexa => "").save
    SignalQuellen.new(:intnummer=>26,  :title=>"EFR", :hexa => "").save
    SignalQuellen.new(:intnummer=>27,  :title=>"APR", :hexa => "").save
    SignalQuellen.new(:intnummer=>28,  :title=>"PTR", :hexa => "").save
    SignalQuellen.new(:intnummer=>29,  :title=>"MXR", :hexa => "").save
    SignalQuellen.new(:intnummer=>30,  :title=>"MCR", :hexa => "").save
    SignalQuellen.new(:intnummer=>31,  :title=>"TER", :hexa => "").save
    SignalQuellen.new(:intnummer=>32,  :title=>"CLR", :hexa => "").save
    SignalQuellen.new(:intnummer=>33,  :title=>"HLR", :hexa => "").save
    SignalQuellen.new(:intnummer=>34,  :title=>"COR", :hexa => "").save
    SignalQuellen.new(:intnummer=>35,  :title=>"GEN", :hexa => "").save
    SignalQuellen.new(:intnummer=>36,  :title=>"UDR", :hexa => "").save
    SignalQuellen.new(:intnummer=>37,  :title=>"SAR", :hexa => "").save
    SignalQuellen.new(:intnummer=>38,  :title=>"SYR", :hexa => "").save
    SignalQuellen.new(:intnummer=>39,  :title=>"STR", :hexa => "").save
    SignalQuellen.new(:intnummer=>40,  :title=>"ONC", :hexa => "").save
    SignalQuellen.new(:intnummer=>41,  :title=>"MXC", :hexa => "").save
    SignalQuellen.new(:intnummer=>42,  :title=>"MAC", :hexa => "").save
    SignalQuellen.new(:intnummer=>43,  :title=>"XSR", :hexa => "").save
    SignalQuellen.new(:intnummer=>44,  :title=>"F9R", :hexa => "").save
    SignalQuellen.new(:intnummer=>45,  :title=>"FDR", :hexa => "").save
    SignalQuellen.new(:intnummer=>46,  :title=>"SMR", :hexa => "").save
    SignalQuellen.new(:intnummer=>47,  :title=>"TLR", :hexa => "").save
    SignalQuellen.new(:intnummer=>48,  :title=>"NLR", :hexa => "").save
    SignalQuellen.new(:intnummer=>49,  :title=>"DSR", :hexa => "").save
    SignalQuellen.new(:intnummer=>50,  :title=>"GVR", :hexa => "").save
    SignalQuellen.new(:intnummer=>51,  :title=>"G0R", :hexa => "").save
    SignalQuellen.new(:intnummer=>52,  :title=>"G1R", :hexa => "").save
    SignalQuellen.new(:intnummer=>53,  :title=>"XDR", :hexa => "").save

  end

  def self.down
    drop_table :signal_quellens
  end
end
