# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  # protect_from_forgery # :secret => 'c8f6e32f84cc898ce4936eb42a9a86cc'

  before_filter :display , :except => :run_tv_qsen


  def display
    if cookies[:system_id].nil? && params[:controller]!='systems'  && params[:controller]!='webpanel'
	flash[:notice] = "<div style='color:red; font-size:17px;'>Please select configuration</div>"
	redirect_to "/systems"
    elsif cookies[:system_id].nil? && (params[:controller]=='systems' && params[:action]!='index') && (params[:controller]=='systems' && params[:action]!='setibt_admin') && (params[:controller]=='systems' && params[:action]!='setadmin') && (params[:controller]=='systems' && params[:action]!='show_clean') && (params[:controller]=='systems' && params[:action]!='create') && (params[:controller]=='systems' && params[:action]!='download') && (params[:controller]=='systems' && params[:action]!='import_configuration') && (params[:controller]=='systems' && params[:action]!='reimport_all_configuration')
	flash[:notice] = "<div style='color:red; font-size:17px;'>Please select configuration</div>"
	redirect_to "/systems"
    end
    unless params[:display].nil? then
      session[:display]=params[:display]
      cookies[:display]=params[:display]
    end

    if session[:mode].nil?
	session[:mode] = 'user'
    end
    @bediengeraete_menu = Bediengeraet.find_all_by_system_id(cookies[:system_id], :conditions => ["name8stellig IS NOT NULL and name8stellig!=''"], :select => "name8stellig, intnummer")
    @frames_menu = Frame.find(:all, :conditions => ["ipadresse != '' and system_id = ?", cookies[:system_id]], :select => "id, intnummer, ipadresse")
    begin
      @system = System.find(cookies[:system_id]) unless cookies[:system_id].nil?
    rescue
      @system = System.new
    end
  end

  def get_units
    return (1..Global::MAX_UNIT).to_a
  end

  def formatstring(str, len)
    begin
      returner = ('"' + str.ljust(len) + '"').to_s
    rescue
      returner = ('"' + "".ljust(len) + '"').to_s
    end
  end

  def formatstr(str)
      returner = ('"' + str + '"').to_s
  end

 def formatnumber2(nbr)
    return "0" + nbr.to_s if nbr.to_i<10
    return nbr.to_s
  end

  def formatnumber3(nbr)
    return "00" + nbr.to_s if nbr.to_i<10
    return "0" + nbr.to_s if nbr.to_i<100
    return nbr.to_s
  end

  def getTallyCollection
    return (0..Global::MAXTALLYBIT).to_a
  end

  def getHLSDCollection
    return (0..256).to_a
  end

  def getSimulatedDestinationCollection
    @sd_val = Range.new(1, Global::MAXSIMULATEDDESTINATION).to_a
    @sd = []
    @sd.push("")
    @sd_val.each {|e| @sd.push(e)}
    return @sd
  end

  def getIpFormat(ip)
	ip_temp = ip.split(".")
	ip = ""
	ip_temp.each do |c|
		if c.length < 3
			if c.to_i<10
				ip << "00" + c.to_i.to_s + "."
			elsif c.to_i<100
				ip << "0" + c.to_i.to_s + "."
			else
				ip << c.to_s + "."
			end
		else
			ip << c.to_s + "."
		end
	end

	return ip.slice(0, ip.length-1)
  end


  def validateUnitPort(unit, port)
	ports = (1..Global::MAX_PORT).to_a

	# ------------
	kv_m = Kreuzschiene.find(:all, :conditions => ["unit =? and system_id =?", unit, @system], :select => "id, port")

	kv_m.each do |m|
		ports.delete(m.port)
	end

	# ------------
	kv_s = Kreuzschiene.find(:all, :conditions => ["unit2 =? and system_id =?", unit, @system], :select => "id, port2")

	kv_s.each do |s|
		ports.delete(s.port2)
	end

	# ------------
	dv = Device.find(:all, :conditions => ["unit =? and system_id =?", unit, @system], :select => "id, port")

	dv.each do |d|
		ports.delete(d.port)
	end

	# ------------
	pn = Bediengeraet.find(:all, :conditions => ["unit =? and system_id =?", unit, @system], :select => "id, port")

	pn.each do |p|
		ports.delete(p.port)
	end

	# ------------
	gp_in = GpInput.find(:all, :conditions => ["unit =? and system_id =?", unit, @system], :select => "id, port")

	gp_in.each do |g|
		ports.delete(g.port)
	end

	# ------------ # ------------
	if port && port != 0
		result = ports << port
	else
		result = ports
	end

	return result.sort
  end

end

