class CreateSignalSenkens < ActiveRecord::Migration
  def self.up
    create_table :signal_senkens do |t|
      t.integer :intnummer
      t.string :title, :length => 3
      t.string :hexa, :length => 10
      t.timestamps
    end
    
    SignalSenken.new(:intnummer=>1,   :title=>"INP", :hexa => "").save
    SignalSenken.new(:intnummer=>2,   :title=>"IN1", :hexa => "").save
    SignalSenken.new(:intnummer=>3,   :title=>"IN2", :hexa => "").save
    SignalSenken.new(:intnummer=>4,   :title=>"IN3", :hexa => "").save
    SignalSenken.new(:intnummer=>5,   :title=>"IN4", :hexa => "").save
    SignalSenken.new(:intnummer=>6,   :title=>"IRT", :hexa => "").save
    SignalSenken.new(:intnummer=>7,   :title=>"DYN", :hexa => "").save
    SignalSenken.new(:intnummer=>8,   :title=>"CMD", :hexa => "").save
    SignalSenken.new(:intnummer=>9,   :title=>"MTS", :hexa => "").save
    SignalSenken.new(:intnummer=>10,  :title=>"HDS", :hexa => "").save
    SignalSenken.new(:intnummer=>11,  :title=>"VTS", :hexa => "").save
    SignalSenken.new(:intnummer=>12,  :title=>"OCS", :hexa => "").save
    SignalSenken.new(:intnummer=>13,  :title=>"ATS", :hexa => "").save
    SignalSenken.new(:intnummer=>14,  :title=>"CCS", :hexa => "").save
    SignalSenken.new(:intnummer=>15,  :title=>"DTS", :hexa => "").save
    SignalSenken.new(:intnummer=>16,  :title=>"RDS", :hexa => "").save
    SignalSenken.new(:intnummer=>17,  :title=>"CDS", :hexa => "").save
    SignalSenken.new(:intnummer=>18,  :title=>"PLS", :hexa => "").save
    SignalSenken.new(:intnummer=>19,  :title=>"CPS", :hexa => "").save
    SignalSenken.new(:intnummer=>20,  :title=>"B0S", :hexa => "").save
    SignalSenken.new(:intnummer=>21,  :title=>"B1S", :hexa => "").save
    SignalSenken.new(:intnummer=>22,  :title=>"B2S", :hexa => "").save
    SignalSenken.new(:intnummer=>23,  :title=>"B3S", :hexa => "").save
    SignalSenken.new(:intnummer=>24,  :title=>"B4S", :hexa => "").save
    SignalSenken.new(:intnummer=>25,  :title=>"B5S", :hexa => "").save
    SignalSenken.new(:intnummer=>26,  :title=>"B6S", :hexa => "").save
    SignalSenken.new(:intnummer=>27,  :title=>"B7S", :hexa => "").save
    SignalSenken.new(:intnummer=>28,  :title=>"STD", :hexa => "").save
    SignalSenken.new(:intnummer=>29,  :title=>"CRM", :hexa => "").save
    SignalSenken.new(:intnummer=>30,  :title=>"PFL", :hexa => "").save
    SignalSenken.new(:intnummer=>31,  :title=>"AFL", :hexa => "").save
    SignalSenken.new(:intnummer=>32,  :title=>"EFS", :hexa => "").save
    SignalSenken.new(:intnummer=>33,  :title=>"APS", :hexa => "").save
    SignalSenken.new(:intnummer=>34,  :title=>"PTS", :hexa => "").save
    SignalSenken.new(:intnummer=>35,  :title=>"MXS", :hexa => "").save
    SignalSenken.new(:intnummer=>36,  :title=>"MCS", :hexa => "").save
    SignalSenken.new(:intnummer=>37,  :title=>"TES", :hexa => "").save
    SignalSenken.new(:intnummer=>38,  :title=>"CLS", :hexa => "").save
    SignalSenken.new(:intnummer=>39,  :title=>"HLS", :hexa => "").save
    SignalSenken.new(:intnummer=>40,  :title=>"COS", :hexa => "").save
    SignalSenken.new(:intnummer=>41,  :title=>"DSP", :hexa => "").save
    SignalSenken.new(:intnummer=>42,  :title=>"UDS", :hexa => "").save
    SignalSenken.new(:intnummer=>43,  :title=>"SAS", :hexa => "").save
    SignalSenken.new(:intnummer=>44,  :title=>"SYS", :hexa => "").save
    SignalSenken.new(:intnummer=>45,  :title=>"STS", :hexa => "").save
    SignalSenken.new(:intnummer=>46,  :title=>"VIS", :hexa => "").save
    SignalSenken.new(:intnummer=>47,  :title=>"XSS", :hexa => "").save
    SignalSenken.new(:intnummer=>48,  :title=>"F9S", :hexa => "").save
    SignalSenken.new(:intnummer=>49,  :title=>"FDS", :hexa => "").save
    SignalSenken.new(:intnummer=>50,  :title=>"SMS", :hexa => "").save
    SignalSenken.new(:intnummer=>51,  :title=>"TLS", :hexa => "").save
    SignalSenken.new(:intnummer=>52,  :title=>"NLS", :hexa => "").save
    SignalSenken.new(:intnummer=>53,  :title=>"DSS", :hexa => "").save
    SignalSenken.new(:intnummer=>54,  :title=>"GVS", :hexa => "").save
    SignalSenken.new(:intnummer=>55,  :title=>"G0S", :hexa => "").save
    SignalSenken.new(:intnummer=>56,  :title=>"G1S", :hexa => "").save
    SignalSenken.new(:intnummer=>57,  :title=>"XDS", :hexa => "").save

  end

  def self.down
    drop_table :signal_senkens
  end
end
