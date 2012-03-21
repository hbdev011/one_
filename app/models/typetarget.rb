class Typetarget < ActiveRecord::Base
  
  belongs_to :target
  belongs_to :bediengeraet
  
 
  def targetname5stellig(kreuzschiene_id, system_id)
    kv = Kreuzschiene.getMatrix(kreuzschiene_id, system_id)
    t = Target.find(:first, :conditions=>["kreuzschiene_id=? and nummer=?", kv.id, self.target_id])
    unless t.nil? or t.name5stellig=="" then
      t.name5stellig
    else
      "____"
    end
  end

  def self.getLastQuelle(bd_id, matrix)
    target = self.find(:all, :conditions => ["bediengeraet_id=? and matrix=?", bd_id, matrix] , :select => "id, target_id", :order => "id DESC")
    return target.nil? ? nil : target.size == 1 ? target[0] : target[1]
  end

  def self.getSenkeCount(bd_id)
	return self.find(:all, :conditions => ["bediengeraet_id =? ", bd_id], :select => "Count(id) as cnt", :order => "tasten_id" )
  end

  def self.getSenke(bd_id, tasten_id)
	return self.find(:first, :conditions => ["bediengeraet_id =? AND tasten_id >= ?",bd_id, tasten_id])
  end
end
