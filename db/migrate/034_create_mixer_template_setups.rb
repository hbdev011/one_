class CreateMixerTemplateSetups < ActiveRecord::Migration
  def self.up
    create_table :mixer_template_setups do |t|
		t.column :intnummer, :integer
		t.column :mixer_template_id, :integer
		t.column :name5stellig , :string
		t.column :name4stellig, :string
		t.column :char6, :string
		t.column :char10, :string
		t.column :comment, :string
		t.column :tallybit, :integer
		t.column :system_id, :integer
		t.timestamps
    end
  end

  def self.down
    drop_table :mixer_template_setups
  end
end
