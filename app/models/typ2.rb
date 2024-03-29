class Typ2 < ActiveRecord::Base
  
  has_many :sources
  has_many :targets
  belongs_to :protocol
  
  
  def self.create(bg_id, system_id)
    
    @panel = Bediengeraet.find(bg_id)
	@panel.update_attributes(:font_quellen => 1, :font_split => 1, :label_quellen => 1, :label_split => 1 )
    @kv = Kreuzschiene.find(:all, :conditions=>["system_id=?", system_id]).map {|u| [u.name, u.id]}
    @panel.typesources.each do |x| x.destroy end 
    @panel.typetargets.each do |x| x.destroy end
    
    # Quellen anlegen
    c=0
    Global::TYP2_NORMALQUELLEN.times  {
      c=c+1
      Typesource.new(:tasten_id=>c, :bediengeraet_id=>@panel.id, :source_id=>0, :sourcetype=>'normal').save
    }

    # Quellen anlegen
    c=0
    Global::TYP2_SPLITQUELLEN.times  {
      c=c+1
      Typesource.new(:tasten_id=>c, :bediengeraet_id=>@panel.id, :source_id=>0, :sourcetype=>'split').save
    }

    # Senke anlegen    
    Typetarget.new(:tasten_id=>1, :bediengeraet_id=>@panel.id, :target_id=>0).save

  end
  
end
