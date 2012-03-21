class CreateTyp4s < ActiveRecord::Migration
  def self.up
    create_table :typ4s do |t|
      t.column :nummer, :string
      t.column :name, :string
      t.column :kv, :integer
      t.timestamps
    end
  end

  def self.down
    drop_table :typ4s
  end
end
