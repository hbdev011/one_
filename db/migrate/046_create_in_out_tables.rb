class CreateInOutTables < ActiveRecord::Migration
  def self.up
    create_table :in_out_tables do |t|
		t.integer :intnummer
		t.integer :system_id
		t.integer :input1
		t.integer :input2
		t.integer :input3
		t.integer :input4
		t.integer :input5
		t.integer :input6
		t.integer :input7
		t.integer :input8
		t.integer :output
		t.string  :function
		t.string  :boolean_expr
      t.timestamps
    end
  end

  def self.down
    drop_table :in_out_tables
  end
end
