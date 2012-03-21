class Kreuzschiene < ActiveRecord::Base

  belongs_to :system
  belongs_to :protocol
  belongs_to :matrix_type, :foreign_key => "mixer_template_id"

  has_many :targets, :order=>"intnummer", :limit=>5
  has_many :sources, :order=>"intnummer", :limit=>5
  has_many :tallies

  def create_io
    Target.create(Global::IOINITIAL, self.id)
    Source.create(Global::IOINITIAL, self.id)
  end

  def create_io_stagetek
    Target.create(Global::IOINITIAL_STAGETEK, self.id)
    Source.create(Global::IOINITIAL_STAGETEK, self.id)
  end

  def getSources
    if self.input.nil? || self.input.blank?
      input = 0
    else
      input = self.input
    end
    Source.find_all_by_kreuzschiene_id(self.id, :limit=>input, :order=>"intnummer")
  end

  def getSources_stagetek
    	Source.find_all_by_kreuzschiene_id(self.id, :order=>"intnummer")
  end

  def getChar6
    Source.find_all_by_kreuzschiene_id(self.id, :select => "id, intnummer, char6", :conditions => ["char6 NOT LIKE?",''], :limit=>self.input, :order=>"id ASC")
  end

  def getTargets
    if self.output.nil? || self.output.blank?
      output = 0
    else
      output = self.output
    end
    Target.find_all_by_kreuzschiene_id(self.id, :limit=>output, :order=>"intnummer")
  end

  def getTargets_stagetek    
    Target.find_all_by_kreuzschiene_id(self.id, :order=>"intnummer")
  end

  def self.getAllMatrix(system_id)
    return self.find(:all, :conditions => ["system_id =?", system_id], :select => "id, name, intnummer, nummer", :order => "id")
  end

  def self.getAllNamedMatrix(system_id)
    return self.find(:all, :conditions => ["system_id =? and kr_type LIKE?", system_id, "MATRIX"], :select => "id, name, intnummer, nummer", :order => "id")
  end

  def getSourceQuelle
    Source.find_all_by_kreuzschiene_id(self.id, :select => "id, intnummer, char6", :conditions => ["char6 not LIKE?",''], :order => "id ASC")
  end

  def getTargetQuelle
    Target.find_all_by_kreuzschiene_id(self.id, :select => "id, intnummer, char6", :conditions => ["char6 not LIKE?",''], :order => "id ASC")
  end

  def self.getKrIdByMatrix(matrix)
    if matrix.nil? || matrix.blank?
      return nil
    else
      @kr = self.find_by_name(matrix, :select => "intnummer")
      return @kr.nil? ? nil : @kr.intnummer
    end
  end

  def self.getMatrixByIntNummer(nummer, system_id)
    if nummer.to_s == "00"
      return ""
    else
      @kr = self.find_by_intnummer_and_system_id(nummer.to_i, system_id.to_i, :select => "name")
      return @kr.nil? ? "" : @kr.name
    end
  end
  
  def self.getMatrix(nummer, system_id)
    return self.find_by_intnummer_and_system_id(nummer, system_id)
  end

end
