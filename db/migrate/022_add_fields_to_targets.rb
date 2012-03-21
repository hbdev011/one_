class AddFieldsToTargets < ActiveRecord::Migration
  def self.up
    add_column "targets", "char6", :string
    add_column "targets", "char10", :string
    add_column "targets", "comment", :string
    add_column "targets", "matrix", :string
    add_column "targets", "quelle", :string
    add_column "targets", "mx_tallybit", :integer
    add_column "targets", "signal", :integer
    add_column "targets", "subclass", :integer
    add_column "targets", "component", :integer
    add_column "targets", "subcomponent", :integer
  end

  def self.down
    remove_column "targets", "char6"
    remove_column "targets", "char10"
    remove_column "targets", "comment"
    remove_column "targets", "matrix"
    remove_column "targets", "quelle"
    remove_column "targets", "mx_tallybit"
    remove_column "targets", "signal"
    remove_column "targets", "subclass"
    remove_column "targets", "component"
    remove_column "targets", "subcomponent"
  end
end
