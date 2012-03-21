class BdtypesController < ApplicationController

  def show
    @bdtypes = Bdtype.find(:all)

    respond_to do |format|
      format.html { render :action => "show" }
    end
  end

  def create
    Bdtype.new(params[:bdtype]).save
    respond_to do |format|
      format.html { redirect_to :action => "show" }
    end
  end

  # PUT /bdtypes/1
  # PUT /bdtypes/1.xml
  def update
    @bdtype = Bdtype.find(params[:id])

    respond_to do |format|
      if @bdtype.update_attributes(params[:bdtype])
        flash[:notice] = 'Bdtype geändert.'
      end
      format.html { redirect_to :action => "show" }
    end
  end

end
