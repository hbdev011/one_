class Umd < ActiveRecord::Base

  belongs_to :system
  belongs_to :target
  belongs_to :source
  belongs_to :kreuzschiene

  def kreuzschienen_name(display)
    if display.nil? || display=='name' then
      kreuzschiene.name unless kreuzschiene.nil?
    else
      kreuzschiene.intnummer unless kreuzschiene.nil?
    end
  end


  def senken_name(display)
    if self.choice.to_s == '0'
	t = Target.find(:first, :conditions=>["kreuzschiene_id=? and intnummer=?", self.kreuzschiene_id, self.target_id])
    else
	t = Source.find(:first, :conditions=>["kreuzschiene_id=? and intnummer=?", self.kreuzschiene_id, self.target_id])
    end

    if display.nil? || display=='name' then
      return t.name5stellig unless t.nil?
    else
      return t.intnummer unless t.nil?
    end

  end

  def self.getLastSenke(kv_id, system_id)
    target = self.find(:all, :conditions => ["kreuzschiene_id=? and system_id=?", kv_id, system_id] , :select => "id, target_id", :order => "id DESC")
    return target.nil? ? nil : target.size == 1 ? target[0] : target[1]
  end

  def get_mon_havarie(id)
	data = Umd.find(:all, :joins => "left join sources on umds.kreuzschiene_id = sources.kreuzschiene_id", :conditions => "sources.intnummer = umds.mon_havarie and umds.id = #{id}", :select => "sources.intnummer as intnummer, sources.name4stellig as name4stellig")
	if !data.nil? && !data.blank?
		return data[0].name4stellig
	else
		return "___"
	end
  end

end

