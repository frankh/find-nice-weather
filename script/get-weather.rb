require('net/http')
require('json')

api_key = "xey7xpg9qkgw6ccnfweycfwt"
weather_url = "/free/v1/weather.ashx?key="
weather_url += api_key
weather_url += "&num_of_days=7"

counter = 0
File.open("weather-geocoded-uk-towns", "w") do |out|
	File.open("geocoded-uk-towns", "r") do |fd|
		# skip first line
		fd.gets
	    while (line = fd.gets)
	        town, lat, long = line.strip.split(/,/)
		print town + "\n"
	        req_url = weather_url + "&q=" + lat+","+long+"&format=json"
		print req_url + "\n"
	        resp = Net::HTTP.get_response('api.worldweatheronline.com', req_url)
		json_resp = JSON.parse(resp.body)
		out.write(town)
		out.write(',')
		out.write(lat)
		out.write(',')
		out.write(long)
		out.write('||')
		json_resp["data"]["weather"].each { |w| 
			out.write(w["date"])
			out.write(',')
			out.write(w["precipMM"])
			out.write(',')
			out.write(w["tempMinC"])
			out.write(',')
			out.write(w["tempMaxC"])
			out.write(',')
			out.write(w["weatherCode"])
			out.write(',')
			out.write(w["weatherDesc"][0]["value"])
			out.write(',')
			out.write(w["windspeedKmph"])
			out.write("||")
		}
		out.write("\n")
 		sleep(1)
	   end
	end
end
