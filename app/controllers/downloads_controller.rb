class DownloadsController < ApplicationController
	def index
		
	end

	def download
		send_file("#{RAILS_ROOT}/conf/ibt.conf", :x_sendfile => true)
	end

	def mixer_templte
		send_file("#{RAILS_ROOT}/conf/mixer_template.conf", :x_sendfile => true)
	end

	def mixer_templte_setup
		send_file("#{RAILS_ROOT}/conf/mixer_template_setup.conf", :x_sendfile => true)
	end
	
	
	def gpio_file
		@system = System.find(cookies[:system_id])
		send_file("#{RAILS_ROOT}/conf/#{@system.id}/#{params[:name]}", :x_sendfile => true)
	end
	
	
	def gpio_conf
		@system = System.find(cookies[:system_id])
		send_file("#{RAILS_ROOT}/conf/#{@system.id}/#{params[:name]}", :x_sendfile => true)
	end
end
