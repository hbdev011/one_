class CreateMatrixTypes < ActiveRecord::Migration
  def self.up
    create_table :matrix_types do |t|
	  t.integer :intnummer
	  t.string :title
	  t.timestamps
    end

	MatrixType.new(:intnummer => 1, :title => "standard").save
  MatrixType.new(:intnummer => 2, :title => "Lawo MONPL").save
  end

  def self.down
    drop_table :matrix_types
  end
end
