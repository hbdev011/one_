class CreateKreuzschienes < ActiveRecord::Migration
  def self.up
    create_table :kreuzschienes, :options => "auto_increment = 0" do |t|
      t.column :intnummer, :integer
      t.column :nummer, :string
      t.column :name, :string
      t.column :protocol_id, :integer
      t.column :input, :integer
      t.column :output, :integer
      t.column :unit, :integer
      t.column :port, :integer
      t.column :system_id, :integer
      t.column :unit2, :integer
      t.column :port2, :integer
      t.column :ip, :string
      t.column :ip2, :string
      t.timestamps
    end
    
    
    
  end

  def self.down
    drop_table :kreuzschienes
  end
end
