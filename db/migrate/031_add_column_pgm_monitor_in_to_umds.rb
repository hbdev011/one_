class AddColumnPgmMonitorInToUmds < ActiveRecord::Migration
  def self.up
	add_column "umds", "pgm_monitor", :string
  end

  def self.down
	remove_column "umds", "pgm_monitor"
  end
end
