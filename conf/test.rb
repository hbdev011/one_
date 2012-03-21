require 'rubygems'
require 'net/http'
require 'open-uri'
require 'rest_client'
=begin
 res = Net::HTTP.post_form(URI.parse('http://localhost:3012/mobile/deals'),
                              {'current_longitude' => "-84.3231", 'current_latitude' => "33.8392", 'distance' => 100})
 puts res.body
=end
#    Net::HTTP.get_print URI.parse('http://localhost:3012/deals_for_map')


require 'cgi'
=begin
url = "http://www.bettervite.com/capture-leads?xAuth=FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF&LeadIP=255.255.255.255&FirstName=John&LastName=Smith&MiddleName=H&Address1=123 Example&Address2=Suite 2&City=Party Beach&State=IL&Zip=00000&Phone1=1234567890&Phone2=1234567890&Email=id.email021@gmail.com&Gender=M&DOB=01/08/2011&Source=www.leadsource.com&Comments=He was very Interesting. Not!&Optintime=2011-02-28 13:02:26.360"
puts URI.encode(url)
exit
resp = Net::HTTP.get_print URI.parse(URI.encode(url))
puts resp.inspect
puts resp.body.inspect
puts resp.headers.inspect
=end
#url = "http://www.bettervite.com/capture-leads?xAuth=FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF&LeadIP=255.255.255.255&FirstName=John&LastName=Smith&MiddleName=H&Address1=123%20Example&Address2=Suite%202&City=Party%20Beach&State=IL&Zip=00000&Phone1=1234567890&Phone2=1234567890&Email=id.email021@gmail.com&Gender=M&DOB=01/08/2011&Source=www.leadsource.com&Comments=He%20was%20very%20Interesting.%20Not!&Optintime=2011-02-28%2013:02:26.360"

#resp = Net::HTTP.get_print URI.parse(URI.encode(url))
=begin
open(url) do |res|
  puts res.status
  puts res.read 
end

      get 'includers'
      get 'notifiers'
=end
=begin
  For setting user's onoff attribute
  /users/:id/onoff 
  POST DATA :onoff => "Online/Offline" # Let make this also boolean
  
  For setting user's status attribute
  /users/:id/status 
  POST DATA :status => "Status" # Do I need to set user's status to Facebook also for now?
  
  For setting Friend's Include attribute
  /friends/:id/include 
  POST DATA :include => 0/1 
  
  For setting Friend's notify attribute
  /friends/:id/notify 
  POST DATA :notify => 0/1
  
  For getting friend with include attibute set at false
  /friends/includers 

  For getting friend with notify attibute set at false
  /friends/notifiers 
=end
  
  a = RestClient.post 'http://localhost:3001/users/1406742/includes.xml', :group_id => "22"  
  #a = RestClient.get 'http://localhost:3001/users/1.json'
  #a = RestClient.delete 'http://localhost:3001/users/515653250/messages/5'
  #a = RestClient.get 'http://localhost:3001/users.xml'
  puts a



