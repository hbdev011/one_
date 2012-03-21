class AddColumnMatrixToTypetargets < ActiveRecord::Migration
  def self.up
    add_column "typetargets", "matrix", :integer
  end

  def self.down
    remove_column "typetargets", "matrix"
  end
end
