class AddColumnMatrixToTypesource < ActiveRecord::Migration
  def self.up
    add_column "typesources", "matrix", :integer
  end

  def self.down
    remove_column "typesources", "matrix"
  end
end
