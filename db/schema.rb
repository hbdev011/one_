# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 52) do

  create_table "bdtypes", :force => true do |t|
    t.integer  "nummer"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bediengeraets", :force => true do |t|
    t.integer  "intnummer"
    t.string   "nummer"
    t.string   "name8stellig"
    t.string   "name4stellig"
    t.integer  "unit"
    t.integer  "port"
    t.integer  "bdtype_id"
    t.integer  "system_id"
    t.integer  "normalquellen_kv_id"
    t.integer  "splitquellen_kv_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sende_matrix_id"
    t.integer  "sende_senke_id"
    t.string   "ip"
  end

  add_index "bediengeraets", ["intnummer"], :name => "index_bediengeraets_on_intnummer"
  add_index "bediengeraets", ["system_id"], :name => "index_bediengeraets_on_system_id"

  create_table "bgs", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bmes", :force => true do |t|
    t.integer  "taste"
    t.integer  "source_id"
    t.integer  "system_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "peview_monitor"
  end

  add_index "bmes", ["taste"], :name => "index_bmes_on_taste"
  add_index "bmes", ["system_id"], :name => "index_bmes_on_system_id"

  create_table "crosspoints", :force => true do |t|
    t.integer  "nummer"
    t.integer  "salvo_id"
    t.integer  "kreuzschiene_id"
    t.integer  "source_id"
    t.integer  "target_id"
    t.integer  "system_id"
    t.string   "stack",               :limit => 10
    t.integer  "frame"
    t.integer  "slot"
    t.string   "parameter",           :limit => 100
    t.string   "value",               :limit => 100
    t.string   "source_single_class", :limit => 100
    t.string   "source_subclass",     :limit => 100
    t.string   "source_component",    :limit => 100
    t.string   "source_subcomponent", :limit => 100
    t.integer  "delay",               :limit => 4,   :default => 0, :null => false
    t.string   "dest_single_class",   :limit => 100
    t.string   "dest_subclass",       :limit => 100
    t.string   "dest_component",      :limit => 100
    t.string   "dest_subcomponent",   :limit => 100
    t.string   "comment",             :limit => 100
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "crosspoints", ["nummer"], :name => "index_crosspoints_on_nummer"
  add_index "crosspoints", ["system_id"], :name => "index_crosspoints_on_system_id"

  create_table "devices", :force => true do |t|
    t.integer  "intnummer"
    t.string   "nummer"
    t.string   "name"
    t.integer  "protocol_id"
    t.integer  "unit"
    t.integer  "port"
    t.string   "ip"
    t.integer  "system_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "families", :force => true do |t|
    t.integer  "nummer"
    t.string   "name"
    t.integer  "system_color_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "frames", :force => true do |t|
    t.integer  "intnummer"
    t.string   "name"
    t.string   "funktion"
    t.string   "ipadresse"
    t.integer  "system_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "frames", ["intnummer"], :name => "index_frames_on_intnummer"
  add_index "frames", ["system_id"], :name => "index_frames_on_system_id"

  create_table "gp_in_signals", :force => true do |t|
    t.integer  "intnummer"
    t.integer  "value"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gp_inputs", :force => true do |t|
    t.integer  "intnummer"
    t.integer  "value"
    t.string   "name"
    t.integer  "system_id"
    t.integer  "unit"
    t.integer  "port"
    t.integer  "byte"
    t.integer  "bit"
    t.integer  "invert",     :limit => 2
    t.integer  "radio",      :limit => 2
    t.string   "comment",    :limit => 16
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "i_type",     :limit => 1
  end

  create_table "gp_nodes", :force => true do |t|
    t.integer  "intnummer"
    t.integer  "system_id"
    t.integer  "value"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gp_out_signals", :force => true do |t|
    t.integer  "intnummer"
    t.integer  "value"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gp_outputs", :force => true do |t|
    t.integer  "intnummer"
    t.integer  "value"
    t.string   "name"
    t.string   "active_name"
    t.string   "inactive_name"
    t.integer  "system_id"
    t.integer  "unit"
    t.integer  "port"
    t.integer  "byte"
    t.integer  "bit"
    t.integer  "invert",        :limit => 2
    t.string   "comment",       :limit => 16
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "mode",          :limit => 1
    t.integer  "o_type",        :limit => 1
  end

  create_table "groups", :force => true do |t|
    t.integer  "intnummer"
    t.integer  "system_id"
    t.string   "value"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "in_out_tables", :force => true do |t|
    t.integer  "intnummer"
    t.integer  "system_id"
    t.integer  "input1"
    t.integer  "input2"
    t.integer  "input3"
    t.integer  "input4"
    t.integer  "input5"
    t.integer  "input6"
    t.integer  "input7"
    t.integer  "input8"
    t.integer  "output"
    t.text     "function"
    t.text     "action_term"
    t.text     "action_term_output"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "boolean_expr"
    t.text     "tt_val"
  end

  create_table "kreuzschienes", :force => true do |t|
    t.integer  "intnummer"
    t.string   "nummer"
    t.string   "name"
    t.integer  "protocol_id"
    t.integer  "input"
    t.integer  "output"
    t.integer  "unit"
    t.integer  "port"
    t.integer  "system_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "unit2"
    t.integer  "port2"
    t.string   "ip"
    t.string   "ip2"
    t.string   "kr_type"
    t.integer  "mixer_template_id"
    t.integer  "ref_matrix_id"
  end

  add_index "kreuzschienes", ["intnummer"], :name => "index_kreuzschienes_on_intnummer"
  add_index "kreuzschienes", ["system_id"], :name => "index_kreuzschienes_on_system_id"

  create_table "matrix_types", :force => true do |t|
    t.integer  "intnummer"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mixer_tallies", :force => true do |t|
    t.integer  "intnummer"
    t.string   "nummer"
    t.string   "name"
    t.integer  "kreuzschiene_id"
    t.integer  "senke_id"
    t.integer  "system_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mixer_template_setups", :force => true do |t|
    t.integer  "intnummer"
    t.integer  "mixer_template_id"
    t.string   "name5stellig"
    t.string   "name4stellig"
    t.string   "char6"
    t.string   "char10"
    t.string   "comment"
    t.integer  "tallybit"
    t.integer  "system_id",         :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mixer_templates", :force => true do |t|
    t.integer  "intnummer"
    t.string   "name"
    t.integer  "system_id"
    t.integer  "input"
    t.integer  "output"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "options", :force => true do |t|
    t.string   "title"
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "protocols", :force => true do |t|
    t.integer  "nummer"
    t.string   "name"
    t.integer  "protocol_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "salvos", :force => true do |t|
    t.integer  "intnummer"
    t.string   "name"
    t.integer  "salvo_type", :limit => 5
    t.integer  "system_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "signal_quellens", :force => true do |t|
    t.integer  "intnummer"
    t.string   "title"
    t.string   "hexa",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "signal_senkens", :force => true do |t|
    t.integer  "intnummer"
    t.string   "title"
    t.string   "hexa",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sources", :force => true do |t|
    t.integer  "intnummer"
    t.integer  "nummer"
    t.string   "name5stellig"
    t.string   "name4stellig"
    t.integer  "kreuzschiene_id"
    t.integer  "bediengeraet_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "char6"
    t.string   "char10"
    t.string   "comment"
    t.string   "cloneinput"
    t.string   "matrix"
    t.string   "quelle"
    t.integer  "tallybit",        :default => 0, :null => false
    t.integer  "mx_matrix"
    t.integer  "mx_senke"
    t.integer  "signal"
    t.integer  "subclass"
    t.integer  "component"
    t.integer  "subcomponent"
    t.integer  "channel",         :default => 1, :null => false
    t.integer  "real_input"
  end

  add_index "sources", ["kreuzschiene_id"], :name => "index_sources_on_kreuzschiene_id"
  add_index "sources", ["intnummer"], :name => "index_sources_on_intnummer"

  create_table "system_colors", :force => true do |t|
    t.integer  "nummer"
    t.string   "name"
    t.string   "red"
    t.string   "green",      :limit => 50, :null => false
    t.string   "blue",       :limit => 50, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "systems", :force => true do |t|
    t.string   "name"
    t.integer  "version"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tallies", :force => true do |t|
    t.integer  "intnummer"
    t.string   "nummer"
    t.string   "name"
    t.integer  "kreuzschiene_id"
    t.integer  "senke_id"
    t.integer  "system_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "targets", :force => true do |t|
    t.integer  "intnummer"
    t.integer  "nummer"
    t.string   "name5stellig"
    t.string   "name4stellig"
    t.integer  "kreuzschiene_id"
    t.integer  "bediengeraet_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "char6"
    t.string   "char10"
    t.string   "comment"
    t.string   "matrix"
    t.string   "quelle"
    t.integer  "mx_tallybit"
    t.integer  "mx_matrix"
    t.integer  "mx_quelle"
    t.integer  "signal"
    t.integer  "subclass"
    t.integer  "component"
    t.integer  "subcomponent"
    t.integer  "channel",         :default => 1, :null => false
    t.integer  "real_output"
  end

  add_index "targets", ["kreuzschiene_id"], :name => "index_targets_on_kreuzschiene_id"
  add_index "targets", ["intnummer"], :name => "index_targets_on_intnummer"

  create_table "typ1s", :force => true do |t|
    t.string   "nummer"
    t.string   "name"
    t.integer  "kv"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "typ2s", :force => true do |t|
    t.string   "nummer"
    t.string   "name"
    t.integer  "kv"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "typ3s", :force => true do |t|
    t.string   "nummer"
    t.string   "name"
    t.integer  "kv"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "typ4s", :force => true do |t|
    t.string   "nummer"
    t.string   "name"
    t.integer  "kv"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "typesources", :force => true do |t|
    t.integer  "bediengeraet_id"
    t.integer  "source_id"
    t.integer  "tasten_id"
    t.string   "sourcetype"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "matrix"
  end

  add_index "typesources", ["bediengeraet_id"], :name => "index_typesources_on_bediengeraet_id"
  add_index "typesources", ["tasten_id"], :name => "index_typesources_on_tasten_id"
  add_index "typesources", ["sourcetype"], :name => "index_typesources_on_sourcetype"

  create_table "typetargets", :force => true do |t|
    t.integer  "bediengeraet_id"
    t.integer  "target_id"
    t.integer  "tasten_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "matrix"
  end

  add_index "typetargets", ["bediengeraet_id"], :name => "index_typetargets_on_bediengeraet_id"
  add_index "typetargets", ["tasten_id"], :name => "index_typetargets_on_tasten_id"

  create_table "umds", :force => true do |t|
    t.integer  "intnummer"
    t.string   "umdnummer"
    t.integer  "kreuzschiene_id"
    t.integer  "target_id"
    t.string   "festtext"
    t.string   "monitor"
    t.string   "gpi"
    t.string   "bme"
    t.string   "mon_havarie"
    t.string   "konfiguration"
    t.integer  "system_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "pgm_monitor"
    t.string   "choice",          :limit => 0, :default => "0", :null => false
    t.string   "type_option",     :limit => 0, :default => "0", :null => false
    t.string   "ip_address"
    t.integer  "panel",                        :default => 0,   :null => false
    t.integer  "vts_input",                    :default => 0,   :null => false
    t.integer  "source_id"
    t.integer  "master_umd"
  end

  add_index "umds", ["intnummer"], :name => "index_umds_on_intnummer"
  add_index "umds", ["system_id"], :name => "index_umds_on_system_id"

end
