class Bediengeraet < ActiveRecord::Base
  
  belongs_to :system
  belongs_to :bdtype
  
  has_many :typesources
  has_many :typetargets
  
  
  #has_many :normalsources, :conditions=>["bediengeraet_id=? and sourcetype='normal'", id]
  #has_many :splitsources, :conditions=>["bediengeraet_id=? and sourcetype='split'", id]
  
  def normalsources
    Typesource.find(:all, :conditions=>["bediengeraet_id=? and sourcetype='normal'", self.id])
  end
  
  def splitsources
    Typesource.find(:all, :conditions=>["bediengeraet_id=? and sourcetype='split'", self.id])
  end
  
  def self.getBediengeraet(nummer, system_id)
    return self.find_by_intnummer_and_system_id(nummer, system_id)
  end
 
  def self.pu_free?(port, unit, system_id, bediengeraet_id, kreuzschiene_id)
    
    return true if (port=="" or unit=="")
    
    if (Bediengeraet.pu_bediengeraet_free(port, unit, system_id, bediengeraet_id)==true && Bediengeraet.pu_kreuz_master_free(port, unit, system_id, kreuzschiene_id)==true  && Bediengeraet.pu_kreuz_slave_free(port, unit, system_id, kreuzschiene_id)==true ) then
      return true
    end
    return false
  end

  
  def self.pu_bediengeraet_free(port, unit, system_id, bediengeraet_id)
    
    unless bediengeraet_id.nil? then
      bgs = Bediengeraet.find(:first, :conditions=>["port=? and unit=? and system_id=? and id!=?", port, unit, system_id, bediengeraet_id])
    else
      bgs = Bediengeraet.find(:first, :conditions=>["port=? and unit=? and system_id=?", port, unit, system_id])
    end
    if bgs.nil? then
        return true
    else
      return false
    end
    
  end
  
  # true: wenn bereits frei
  def self.pu_kreuz_master_free(port, unit, system_id, kreuzschiene_id)
    
      unless kreuzschiene_id.nil? then
        kreuz = Kreuzschiene.find(:first, :conditions=>["port=? and unit=? and system_id=? and id!=?", port, unit, system_id, kreuzschiene_id])
      else
        kreuz = Kreuzschiene.find(:first, :conditions=>["port=? and unit=? and system_id=?", port, unit, system_id])
      end
      
      if kreuz.nil? then
        return true
      else
        return false
      end

  end
  
  def self.pu_kreuz_slave_free(port, unit, system_id, kreuzschiene_id)
    
      unless kreuzschiene_id.nil? then
        kreuz = Kreuzschiene.find(:first, :conditions=>["port2=? and unit2=? and system_id=? and id!=?", port, unit, system_id, kreuzschiene_id])
      else
        kreuz = Kreuzschiene.find(:first, :conditions=>["port2=? and unit2=? and system_id=?", port, unit, system_id])
      end
      
      if kreuz.nil? then
        return true
      else
        return false
      end

  end
  
  # true: wenn bereits frei
  def self.pu_device_free(port, unit, system_id, device_id)

      unless device_id.nil? then
        device = Device.find(:first, :conditions=>["port=? and unit=? and system_id=? and id!=?", port, unit, system_id, device_id])
      else
        device = Device.find(:first, :conditions=>["port=? and unit=? and system_id=?", port, unit, system_id])
      end

      if device.nil? then
        return true
      else
        return false
      end

  end
  
end
