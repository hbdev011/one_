# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password


  def formatnumber4(nbr)
    return "000" + nbr.to_s if nbr.to_i<10
    return "00" + nbr.to_s if nbr.to_i<100
    return "0" + nbr.to_s if nbr.to_i<1000
    return nbr.to_s
  end

end

