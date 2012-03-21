class OptionsController < ApplicationController
	require 'zip/zip'
  	require 'zip/zipfilesystem'

	def index
		@vs_nr = Option.getIbtVersionOption
		@opt = [0, 1]
		@content = Option.getIbtContent
		@next = Option.getNextOption
		@s_matrix = Option.getSimulateMatrix
		@multiviewer_opt = Global::MULTIVIEWER.sort_on("value")
		@multiviewer = Option.getMultiViewer
	end

	def update
		if params[:id] == "1"
			@tally = Option.getTallyOption
			@tally.update_attributes(:value => params[:val])
		end

		if params[:id] == "2"
			@vs_nr = Option.getIbtVersionOption
			@vs_nr.update_attributes(:value => params[:val])
		end

		if params[:id] == "4"
			@next = Option.getNextOption
			@next.update_attributes(:value => params[:val])
		end

		if params[:id] == "5"
			@s_matrix = Option.getSimulateMatrix
			@s_matrix.update_attributes(:value => params[:val])
		end

		if params[:id] == "6"
			@mv = Option.getMultiViewer
			@mv.update_attributes(:value => params[:val])
		end

		render :update do |page|
		end
	end

	def update_ibt_content
		@content = Option.getIbtContent
		@content.update_attributes(:value => params[:option][:content])
		render :update do |page|
		end
	end

end
