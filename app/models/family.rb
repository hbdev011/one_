class Family < ActiveRecord::Base
  belongs_to :system_color
  has_many :sources
  has_many :targets
  #acts_as_list :position
  #acts_as_list :nummer

  def self.get_family(nummer)
		if !nummer.nil?
	    return Family.find_by_nummer(nummer).name	
		end
  end
end
