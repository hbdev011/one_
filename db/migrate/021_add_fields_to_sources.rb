class AddFieldsToSources < ActiveRecord::Migration
  def self.up
    add_column "sources", "char6", :string
    add_column "sources", "char10", :string
    add_column "sources", "comment", :string
    add_column "sources", "cloneinput", :string
    add_column "sources", "matrix", :string
    add_column "sources", "quelle", :string
    add_column "sources", "tallybit", :string
    add_column "sources", "mx_matrix", :integer
    add_column "sources", "mx_senke", :integer
    add_column "sources", "signal", :integer
    add_column "sources", "subclass", :integer
    add_column "sources", "component", :integer
    add_column "sources", "subcomponent", :integer
  end

  def self.down
    remove_column "sources", "char6"
    remove_column "sources", "char10"
    remove_column "sources", "comment"
    remove_column "sources", "matrix"
    remove_column "sources", "quelle"
    remove_column "sources", "cloneinput"
    remove_column "sources", "tallybit"
    remove_column "sources", "mx_matrix"
    remove_column "sources", "mx_senke"
    remove_column "sources", "signal"
    remove_column "sources", "subclass"
    remove_column "sources", "component"
    remove_column "sources", "subcomponent"
  end
end
