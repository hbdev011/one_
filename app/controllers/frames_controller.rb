class FramesController < ApplicationController
  
   # PUT /kreuzschienes/1
  # PUT /kreuzschienes/1.xml
  def update
    
    @frame = Frame.find(params[:frame][:id])

    if @frame.update_attributes(params[:frame])
      flash[:notice] = 'Frame wurde gespeichert'
    else
      flash[:notice] = 'FEHLER'
    end
    
    respond_to do |format|  
      format.html { redirect_to :controller=>'systems', :action => "show", :id=>@frame.system }
    end
    

  end
  
end
