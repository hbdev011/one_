class CreateSystemAssoziations < ActiveRecord::Migration
  def self.up
    create_table :system_assoziations do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :system_assoziations
  end
end
