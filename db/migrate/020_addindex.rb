class Addindex < ActiveRecord::Migration
  def self.up
    add_index :frames, :intnummer
    add_index :frames, :system_id
    
    add_index :crosspoints, :nummer
    add_index :crosspoints, :system_id
    
    add_index :sources, :kreuzschiene_id
    add_index :sources, :intnummer
    
    add_index :targets, :kreuzschiene_id
    add_index :targets, :intnummer
    
    add_index :kreuzschienes, :intnummer
    add_index :kreuzschienes, :system_id
    
    add_index :bediengeraets, :intnummer
    add_index :bediengeraets, :system_id
    
    add_index :typesources, :bediengeraet_id
    add_index :typesources, :tasten_id
    add_index :typesources, :sourcetype
    
    add_index :typetargets, :bediengeraet_id
    add_index :typetargets, :tasten_id
    
    add_index :bmes, :taste
    add_index :bmes, :system_id
    
    add_index :umds, :intnummer
    add_index :umds, :system_id
    
  end

  def self.down
    
    remove_index :frames, :intnummer
    remove_index :frames, :system_id
    
    remove_index :crosspoints, :nummer
    remove_index :crosspoints, :system_id
    
    remove_index :sources, :kreuzschiene_id
    remove_index :sources, :intnummer
    
    remove_index :targets, :kreuzschiene_id
    remove_index :targets, :intnummer
    
    remove_index :kreuzschienes, :intnummer
    remove_index :kreuzschienes, :system_id
    
    remove_index :bediengeraets, :intnummer
    remove_index :bediengeraets, :system_id
    
    remove_index :typesources, :bediengeraet_id
    remove_index :typesources, :tasten_id
    remove_index :typesources, :sourcetype
    
    remove_index :typetargets, :bediengeraet_id
    remove_index :typetargets, :tasten_id
   
    remove_index :bmes, :taste
    remove_index :bmes, :system_id
    
    remove_index :umds, :intnummer
    remove_index :umds, :system_id
       
  end
end
