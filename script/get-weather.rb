require('net/http')
require('json')

api_key = "xey7xpg9qkgw6ccnfweycfwt"
weather_url = "/free/v1/weather.ashx?key="
weather_url += api_key
weather_url += "&num_of_days=7"

def score_weather(precipMM, tempMinC, tempMaxC, weatherCode, windspeedKmph)
	precipMM = precipMM.to_i
	tempMinC = tempMinC.to_i
	tempMaxC = tempMaxC.to_i
	weatherCode = weatherCode.to_i
	windspeedKmph = windspeedKmph.to_i

	score = 0
	if precipMM == 0
		score += 10
	else
		score -= 5*precipMM
	end

	score += tempMinC
	score += tempMaxC

	if windspeedKmph > 10
		score -= windspeedKmph / 2
	end

	if weatherCode == 113
		score += 10
	elsif weatherCode == 116
		score += 5
	elsif weatherCode <= 170
	else
		score -= 10
	end
	return score
end
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
			print req_url + "\n"
			resp = Net::HTTP.get_response('api.worldweatheronline.com', req_url)
			json_resp = JSON.parse(resp.body)
			out.write("#{town},#{lat},#{long}||")
			total_score = 0
			min_score = 999999
			json_resp["data"]["weather"].each { |w| 
				result_keys = ["date", "precipMM", "tempMinC", "tempMaxC", "weatherCode", "windspeedKmph"]
				result_data = result_keys.collect{|x| w[x]}
				this_score = score_weather(*result_data[1..6])
				total_score += this_score
				
				if this_score < min_score
					min_score = this_score
				end
				
				out.write(result_data.join(","))
				out.write("||")
			}
			out.write("\n")
			avg_score = total_score/7
			normalised_score = (min_score + avg_score) / 2
			print "Score is #{normalised_score}"
			if normalised_score > max_score
				max_score = normalised_score
				print "Max score is #{max_score}"
			end
			sleep(1)
		end
	end
end

