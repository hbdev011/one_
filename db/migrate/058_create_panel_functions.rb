class CreatePanelFunctions < ActiveRecord::Migration
  def self.up
    create_table :panel_functions do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :panel_functions
  end
end
