class CreateFamilyPanels < ActiveRecord::Migration
  def self.up
    create_table :family_panels do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :family_panels
  end
end
