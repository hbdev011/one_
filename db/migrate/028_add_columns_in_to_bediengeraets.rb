class AddColumnsInToBediengeraets < ActiveRecord::Migration
  def self.up
    add_column "bediengeraets", "sende_matrix_id", :integer
    add_column "bediengeraets", "sende_senke_id", :integer
    add_column "bediengeraets", "ip", :string
  end

  def self.down
    remove_column "bediengeraets", "sende_matrix_id"
    remove_column "bediengeraets", "sende_senke_id"
    remove_column "bediengeraets", "ip"
  end
end
