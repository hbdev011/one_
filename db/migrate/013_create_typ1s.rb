class CreateTyp1s < ActiveRecord::Migration
  def self.up
    create_table :typ1s do |t|
      t.column :nummer, :string
      t.column :name, :string
      t.column :kv, :integer
      t.timestamps
    end
  end

  def self.down
    drop_table :typ1s
  end
end
