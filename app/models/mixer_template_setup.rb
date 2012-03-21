class MixerTemplateSetup < ActiveRecord::Base
	belongs_to :mixer_template

	def self.build_mixer_template_setup(system_id)
		# MS_01=01,ch4,ch5,ch6,ch10,001,CM1
		f = File.open("conf/mixer_template_setup.conf", 'r')

		f.each do |line_complete|
			line_complete.split(/\r/).each do |line|
				tupel = line.delete('"').strip.split("=")
				if tupel.size > 1
					defi = tupel[0].split("_")
					attribute = tupel[1].split(",")

					self.new(:mixer_template_id => defi[1].to_i, :intnummer => attribute[0].to_i, :name4stellig => attribute[1].strip, :name5stellig => attribute[2].strip, :char6 => attribute[3].strip, :char10 => attribute[4].strip, :tallybit => attribute[5].to_i, :comment => attribute[6].strip, :system_id => system_id).save
				end
			end
		end
	end
end
