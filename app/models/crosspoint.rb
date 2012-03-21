class Crosspoint < ActiveRecord::Base

  belongs_to :system
  belongs_to :kreuzschiene
  belongs_to :source
  belongs_to :target
  belongs_to :salvo
  attr_accessor :stack1,:stack2
  before_save :modify_stack
	belongs_to :signal_quellen, :foreign_key => "source_single_class"
	belongs_to :signal_quellen, :foreign_key => "dest_single_class"

  def modify_stack
    self.stack = ("#{self.stack1}.#{self.stack2}").to_f
  end

  def kreuzschienen_name
	return "def?" if self.kreuzschiene.nil?
	self.kreuzschiene.name
  end

  def targetname
	t = Target.find(:first, :conditions=>["kreuzschiene_id=? and id=?", kreuzschiene_id, self.target_id])
	unless t.nil? then
		t.name5stellig
	else
		""
	end
  end

  def sourcename
	t = Source.find(:first, :conditions=>["kreuzschiene_id=? and id=?", kreuzschiene_id, self.source_id])
	unless t.nil? then
		t.name5stellig
	else
		""
	end
  end

  def self.getLastkv(kv_id, system_id, id)
	source = self.find(:all, :conditions => ["kreuzschiene_id=? and system_id=? and id!=?", kv_id, system_id, id], :select => "id, source_id, target_id", :order => "id DESC", :limit => 2)
	return source.nil? ? nil : source.size == 1 ? source[0] : source[1]
  end

  def self.get_salvo_setups(system_id, salvo_id)
	return self.find(:all, :conditions => ["system_id=? and salvo_id=?", system_id, salvo_id])
  end

end

