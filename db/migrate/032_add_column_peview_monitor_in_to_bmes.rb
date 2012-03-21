class AddColumnPeviewMonitorInToBmes < ActiveRecord::Migration
  def self.up
    add_column "bmes", "peview_monitor", :integer
  end

  def self.down
    remove_column "bmes", "peview_monitor"
  end
end
