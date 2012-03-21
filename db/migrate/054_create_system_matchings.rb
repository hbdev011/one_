class CreateSystemMatchings < ActiveRecord::Migration
  def self.up
    create_table :system_matchings do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :system_matchings
  end
end
