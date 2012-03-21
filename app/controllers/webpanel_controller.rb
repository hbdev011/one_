class WebpanelController < ApplicationController

	layout "webpanel"

#  require 'faye'
#  require 'eventmachine'

	def index
	  if request.post?
  	    Juggernaut.send_to_all("moveSlider(#{params[:fader]})")
#	    fade_values = params[:fader]
#	    # Connects to Web Socket server at host example.com port 10081.
#      EM.run {
#        client = Faye::Client.new('http://192.168.35.25:8000/faye')

#        # Sends a message to the server.
#        client.publish('/fader', 'val' => params[:fader])
#      }
      render :nothing => true
	  end
	end
end
