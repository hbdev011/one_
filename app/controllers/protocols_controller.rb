class ProtocolsController < ApplicationController

  def show
	@protocols = Protocol.find(:all)
	@type_of_protocol = Global::PORT_RESTRICTION.sort_on("value")

	respond_to do |format|
		format.html { render :action => "show" }
	end
  end

  # PUT /protocols/1
  # PUT /protocols/1.xml
  def update
	@protocol = Protocol.find(params[:id])
	@protocol.update_attributes(params[:protocol])

	render :update do |page|
		page.replace_html "msg", "<font style='color:green;'> Protokoll erfolgreich aktualisiert </font>"
	end
  end

  def delete_protocol
	Protocol.find(params[:id]).destroy
	respond_to do |format|
		format.html { redirect_to :action => "show" }
	end
  end

  def create_protocol
    Protocol.new(params[:new_protocol]).save
    respond_to do |format|
      format.html { redirect_to :action => "show" }
    end
  end
end
