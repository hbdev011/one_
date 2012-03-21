class UploadsController < ApplicationController
	def index
		
	end

	def uploadFile
		post = Datafile.save(params[:upload])
		flash[:msg] = "Datei erfolgreich hochgeladen"
		# Datei erfolgreich hochgeladen
		redirect_to :action => "index"
	end

end
