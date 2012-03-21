class Source < ActiveRecord::Base

  belongs_to :kreuzschiene
  belongs_to :signal_quellen, :foreign_key => "signal"
  belongs_to :family
  has_many :type_sources

  def self.create(nbr, kreuzschiene_id)
    c=0
    nbr.to_i.times  {
      c=c+1
      Source.new(:nummer=>c, :intnummer=>c, :name5stellig=>'', :name4stellig=>'', :kreuzschiene_id=>kreuzschiene_id, :mx_senke => nil, :mx_matrix => nil).save
    }
  end

  def self.getSourceCloneId(cloneinput)
    return self.find(cloneinput, :select => "id, intnummer")
  end

  def self.getSourceIdByCloneinput(kr_id, nummer)
    @id = self.find_by_kreuzschiene_id_and_intnummer(kr_id, nummer.to_i, :select => "id")
    return @id.nil? ? "" : @id.id
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
    if nummer.to_s == "000" || matrix.to_s == "00"
      return ""
    else
      @kr = Kreuzschiene.getMatrix(matrix.to_i, system.id)
      @quelle = self.find_by_kreuzschiene_id_and_intnummer(@kr.id, nummer.to_i, :select => "id")
      return @quelle.nil? ? "" : @quelle.id
    end
  end

  def self.getCloneRecord(nummer, kv_id)
    return self.find_by_intnummer_and_kreuzschiene_id(nummer, kv_id)
  end

	def self.getLastSenke(kv_id, mx_matrix)
		source = self.find(:all, :conditions => ["kreuzschiene_id=? and mx_matrix=?", kv_id, mx_matrix] , :select => "id, mx_senke", :order => "id DESC", :limit => 2)
		return source.nil? ? nil : source.size == 1 ? source[0] : source[1]
	end

	def self.getLastQuelle(kv_id, matrix)
		source = self.find(:all, :conditions => ["kreuzschiene_id=? and matrix=?", kv_id, matrix] , :select => "id, quelle", :order => "id DESC")
		return source.nil? ? nil : source.size == 1 ? source[0] : source[1]
	end

	def self.getQuelleNameByNummer(nummer, matrix, system)
		@kr = Kreuzschiene.getMatrix(matrix, system)
		@quelle = self.find_by_kreuzschiene_id_and_intnummer(@kr.id, nummer.to_i, :select => "id, char6")
		return @quelle.nil? ? "" : @quelle.char6
	end


end
