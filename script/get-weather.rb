require('net/http')
require('json')

api_key = "xey7xpg9qkgw6ccnfweycfwt"
weather_url = "/free/v1/weather.ashx?key="
weather_url += api_key
weather_url += "&num_of_days=7"

def very_nice_day(precipMM, tempMinC, tempMaxC, weatherCode, windspeedKmph)
	return (precipMM == 0 and tempMinC >= 10 and tempMaxC >= 18 and \
		tempMaxC <= 28 and weatherCode <= 116 and windspeedKmph <= 15)
end

def nice_day(precipMM, tempMinC, tempMaxC, weatherCode, windspeedKmph)
	return (precipMM == 0 and tempMinC >= 10 and tempMaxC <= 30 \
		and weatherCode <= 116 and windspeedKmph <= 20)
end

def ok_day(precipMM, tempMinC, tempMaxC, weatherCode, windspeedKmph)
	return (precipMM <= 2 and tempMinC >= 5 and tempMaxC <= 35 \
		and weatherCode <= 170 and windspeedKmph <= 30)
end

def score_weather(*args)
	args = args.collect{|x| x.to_f}

	if very_nice_day(*args)
		return 1.1
	elsif nice_day(*args)
		return 1
	elsif ok_day(*args)
		return 0.49
	else
		return 0
	end
end

def collect_weather()
	max_score = -999
	counter = 0
	File.open("weather-geocoded-uk-towns", "w") do |out|
		File.open("geocoded-uk-towns", "r") do |fd|
			# skip first line
			fd.gets
			while (line = fd.gets)
				town, lat, long = line.strip.split(/,/)
				print town + "\n"
				req_url = weather_url + "&q=" + lat+","+long+"&format=json"
				resp = Net::HTTP.get_response('api.worldweatheronline.com', req_url)
				json_resp = JSON.parse(resp.body)
				out.write("#{town},#{lat},#{long}||")
				total_score = 0
				json_resp["data"]["weather"].each { |w| 
					result_keys = ["date", "precipMM", "tempMinC", "tempMaxC", "weatherCode", "windspeedKmph"]
					result_data = result_keys.collect{|x| w[x]}
					this_score = score_weather(*result_data[1..6])
					total_score += this_score
					
					out.write(result_data.join(","))
					out.write("||")
				}
				out.write("\n")
				print "Score is #{total_score}\n"
				if total_score > max_score
					max_score = total_score
					print "Max score is #{max_score}\n"
				end
				print "\n"
				sleep(1)
			end
		end
	end
end

def read_weather()
	File.open("weather-geocoded-uk-towns", "r") do |fd|
		while (line = fd.gets)
			town_info, today, *forecasts = line.strip.split(/\|\|/)
			town, lat, long = town_info.strip.split(/,/)

			total_score = 0
			forecasts.each { |w| 
				date, *data = w.strip.split(/,/).collect{|x| x.to_i}
				total_score += score_weather(*data)
			}

			print town + "\t#{total_score}\n"
		end
	end
end

read_weather()