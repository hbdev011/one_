class CreateTyp6s < ActiveRecord::Migration
  def self.up
    create_table :typ6s do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :typ6s
  end
end
