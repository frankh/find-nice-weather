# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

#Abbots Langley,51.707275,-0.4183259||2013-06-19,1.9,14,25,119,12||2013-06-20,1.5,12,19,266,16||2013-06-21,0.7,11,19,122,24||2013-06-22,12.6,8,15,296,30||2013-06-23,3.2,9,15,353,28||2013-06-24,4.1,6,14,353,21||2013-06-25,0.0,7,14,113,15||

Town.delete_all
Weather.delete_all
open("db/weather-geocoded-uk-towns") do |towns|
	towns.read.each_line do |town_info|
		town, *weather = town_info.chomp.split('||')
		name, lat, lng = town.split(',')

		town = Town.create!(:name => name, :lat => lat, :lng => lng)
		weather.each do |w|
			date, precip_mm, min_temp, max_temp, weather_code, wind_spd = w.split(',')
			Weather.create!(
			    :town_id => town.id,
			    :date => date,
			    :min_temp => min_temp,
			    :max_temp => max_temp,
			    :precip_mm => precip_mm,
			    :wind_spd => wind_spd,
			    :weather_code => weather_code
			)
		end
	end
end
