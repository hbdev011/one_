class Target < ActiveRecord::Base

  belongs_to :kreuzschiene
  belongs_to :signal_senken, :foreign_key => "signal"
  belongs_to :family

  def self.create(nbr, kreuzschiene_id)
    c=0
    nbr.to_i.times  {
      c=c+1
      Target.new(:nummer=>c, :intnummer=>c, :name5stellig=>'', :name4stellig=>'', :kreuzschiene_id=>kreuzschiene_id, :mx_tallybit => nil, :mx_matrix => nil, :mx_quelle => nil, :red => 0, :green => 0, :yellow => 0, :blue => 0).save
    }
  end

  def self.getNummerByQuelle(quelle)
    if quelle.nil? || quelle.blank?
      return nil
    else
      @nummer = self.find(quelle, :select => "intnummer")
      return @nummer.nil? ? nil : @nummer.intnummer
    end
  end 

  def self.getQuelleByNummer(nummer, matrix)
    system = System.find(cookies[:system_id])
    if nummer.to_s == "000"
      return ""
    else
      @kr = Kreuzschiene.getMatrix(matrix, system)
      @quelle = self.find_by_kreuzschiene_id_and_intnummer(@kr.id, nummer.to_i, :select => "id")
      return @quelle.nil? ? "" : @quelle.id
    end
  end

	def self.getQuelleByNummer1(nummer, matrix, system)
		@kr = Kreuzschiene.getMatrix(matrix, system)
		@quelle = self.find_by_kreuzschiene_id_and_intnummer(@kr.id, nummer.to_i, :select => "id, nummer")
		return @quelle.nil? ? "" : @quelle.nummer
	end

	def self.getQuelleNameByNummer(nummer, matrix, system)
		@kr = Kreuzschiene.getMatrix(matrix, system)
		@quelle = self.find_by_kreuzschiene_id_and_intnummer(@kr.id, nummer.to_i, :select => "id, char6")
		return @quelle.nil? ? "" : @quelle.char6
	end

	def self.getLastSenke(kv_id, mx_matrix)
		target = self.find(:all, :conditions => ["kreuzschiene_id=? and mx_matrix=?", kv_id, mx_matrix] , :select => "id, mx_quelle", :order => "id DESC")
		return target.nil? ? nil : target.size == 1 ? target[0] : target[1]
	end

	def self.getLastQuelle(kv_id, matrix)
		target = self.find(:all, :conditions => ["kreuzschiene_id=? and matrix=?", kv_id, matrix] , :select => "id, quelle", :order => "id DESC")
		return target.nil? ? nil : target.size == 1 ? target[0] : target[1]
	end
  
	def self.getSenkeNameByNummer(nummer, matrix, system)
		@kr = Kreuzschiene.getMatrix(matrix, system)
		@senke = self.find_by_kreuzschiene_id_and_intnummer(@kr.id, nummer.to_i, :select => "id, char6")
		return @senke.nil? ? "" : @senke.char6
	end


end
