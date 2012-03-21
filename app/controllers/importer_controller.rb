class ImporterController < ApplicationController
  
  # GET /kreuzschienes/1
  # GET /kreuzschienes/1.xml
  def readFile

    sys = System.new(:name=>"LeseProto", :version=>1)
    sys.save
    logger.info "System created " + sys.inspect
    
    f = File.open("ibt.conf", 'r') 
    f.each do |line|
      
      unless line[0]==";" then

        tupel = line.split("=")
        attribut = tupel[1].split(",")
        definition=tupel[0].split("_")

        logger.info "Line: " + line
         
        if definition[0]=="UN" and definition[1]=="DEF" then
          frame = Frame.new(:name=>'Unit ' + attribut[2] , :funktion=>'Master', :ipadresse=> + attribut[1], :system_id=>sys.id)
          frame.save
          logger.info "Frame created " + frame.inspect
        end

      end     
    end
    f.close
    
  end
  
  
end
