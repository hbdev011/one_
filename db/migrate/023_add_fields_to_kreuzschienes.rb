class AddFieldsToKreuzschienes < ActiveRecord::Migration
  def self.up
    add_column "kreuzschienes", "ip", :string
    add_column "kreuzschienes", "ip2", :string
    add_column "kreuzschienes", "kr_type", :string
    add_column "kreuzschienes", "mixer_template_id", :integer
    add_column "kreuzschienes", "ref_matrix_id", :integer
  end

  def self.down
    remove_column "kreuzschienes", "ip"
    remove_column "kreuzschienes", "ip2"
    remove_column "kreuzschienes", "kr_type"
    remove_column "kreuzschienes", "mixer_template_id"
    remove_column "kreuzschienes", "ref_matrix_id"
  end
end
