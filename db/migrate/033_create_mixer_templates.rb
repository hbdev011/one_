class CreateMixerTemplates < ActiveRecord::Migration
  def self.up
	create_table :mixer_templates do |t|
		t.column :intnummer, :integer
		t.column :name, :string
		t.column :system_id, :integer
		t.column :input, :integer
		t.column :output, :integer
		t.timestamps
	end
  end

  def self.down
	drop_table :mixer_templates
  end
end
