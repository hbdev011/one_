class MixerTemplate < ActiveRecord::Base
	belongs_to :system
	has_many :mixer_template_setups

	def self.build_mixer_template(system_id)
		# MT_01=04,SAD1,072,037
		f = File.open("conf/mixer_template.conf", 'r')

		f.each do |line_complete|
			line_complete.split(/\r/).each do |line|
				tupel = line.delete('"').strip.split("=")
				if tupel.size > 1
					defi = tupel[0].split("_")
					attribute = tupel[1].split(",")
	
					self.new(:intnummer => attribute[0].to_i, :name => attribute[1].to_s, :system_id => system_id, :input => attribute[2].to_i, :output => attribute[3].to_i).save
				end
			end
		end
	end
end
