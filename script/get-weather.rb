require('net/http')

api_key = "xey7xpg9qkgw6ccnfweycfwt"
weather_url = "/free/v1/weather.ashx?key="
weather_url += api_key
puts weather_url

counter = 0
File.open("weather-geocoded-uk-towns", "w") do |out|
	File.open("geocoded-uk-towns", "r") do |fd|
		# skip first line
		fd.gets
	    while (line = fd.gets)
	        town, lat, long = line.split(/,/)
	        req_url = weather_url + "&q=" + lat+","+long + "&format=json"
	        resp = Net::HTTP.get_response('api.worldweatheronline.com', req_url)
	    end
	end
end