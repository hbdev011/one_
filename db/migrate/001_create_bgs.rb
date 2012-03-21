class CreateBgs < ActiveRecord::Migration
  def self.up
    create_table :bgs do |t|
        t.column :name, :string
        t.timestamps
    end
  end

  def self.down
    drop_table :bgs
  end
end
