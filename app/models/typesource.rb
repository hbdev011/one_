class Typesource < ActiveRecord::Base

  belongs_to :source
  belongs_to :bediengeraet

  def sourcename5stellig(kreuzschiene_id, system_id)
  kv = Kreuzschiene.getMatrix(kreuzschiene_id, system_id)
	s = Source.find(:first, :conditions=>["kreuzschiene_id=? and nummer=?", kv.id, self.source_id])
	unless s.nil? or s.name5stellig=="" then
		s.name5stellig 
	else
		"____"
	end
  end

  def self.getLastQuelle(bd_id, matrix)
	source = self.find(:all, :conditions => ["bediengeraet_id=? and matrix=?", bd_id, matrix] , :select => "id, source_id", :order => "id DESC")
	return source.nil? ? nil : source.size == 1 ? source[0] : source[1]
  end

  def self.getNormalQuelleCount(bd_id)
	return self.find(:all, :conditions => ["bediengeraet_id =? and sourcetype =? ", bd_id, "normal"], :select => "Count(id) as cnt", :order => "tasten_id" )
  end
  
  def self.getNormalQuelle(bd_id, tasten_id)
  	return self.find(:first, :conditions => ["bediengeraet_id =? AND tasten_id >= ? AND sourcetype =?",bd_id, tasten_id, "normal"])
  end

  def self.getSplitQuelleCount(bd_id)
	return self.find(:all, :conditions => ["bediengeraet_id =? and sourcetype =? ", bd_id, "split"], :select => "Count(id) as cnt", :order => "tasten_id" )
  end

  def self.getSplitQuelle(bd_id, tasten_id)
	return self.find(:first, :conditions => ["bediengeraet_id =? AND tasten_id >= ? AND sourcetype =?",bd_id, tasten_id, "split"])
  end

end
