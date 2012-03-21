class BgsController < ApplicationController
  # GET /bgs
  # GET /bgs.xml
  def index
    @bgs = Bg.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @bgs }
    end
  end

  # GET /bgs/1
  # GET /bgs/1.xml
  def show
    #@bg = Bg.find(params[:id])
    
    @number = params[:number]
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @bg }
    end
  end

  # GET /bgs/new
  # GET /bgs/new.xml
  def new
    @bg = Bg.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @bg }
    end
  end

  # GET /bgs/1/edit
  def edit
    @bg = Bg.find(params[:id])
  end

  # PUT /bgs/1
  # PUT /bgs/1.xml
  def update
    @bg = Bg.find(params[:id])

    respond_to do |format|
      if @bg.update_attributes(params[:bg])
        flash[:notice] = 'Bg was successfully updated.'
        format.html { redirect_to(@bg) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @bg.errors, :status => :unprocessable_entity }
      end
    end
  end

end
