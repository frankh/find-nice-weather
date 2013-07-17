require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module FindNiceWeather
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
  end

  class UpdateWeatherJob
    def run
      puts "Running job."

      Weather.where('date < ?', Time.now.utc).destroy_all 

      def perfect_day(precipMM, tempMinC, tempMaxC, weatherCode, windspeedKmph)
          return (precipMM == 0 and tempMinC >= 15 and tempMaxC >= 22 and \
              tempMaxC <= 29 and weatherCode <= 113 and windspeedKmph <= 15)
      end

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

          if perfect_day(*args)
              return 1.5
          elsif very_nice_day(*args)
              return 1.3
          elsif nice_day(*args)
              return 1
          elsif ok_day(*args)
              return 0.49
          else
              return 0
          end
      end

      begin
        Town.find(:all, 
          :order => "weather_update asc", 
          :limit => 1, :include => 'weather').each do |town|
          puts "Updating #{town.name}"

          require('net/http')
          require('json')
   
          api_key = "xey7xpg9qkgw6ccnfweycfwt"
          weather_url = "/free/v1/weather.ashx?key="
          weather_url += api_key
          weather_url += "&num_of_days=7"
   
          town.weather.each { |w| w.destroy }

          req_url = "#{weather_url}&q=#{town.lat},#{town.lng}&format=json"
          resp = Net::HTTP.get_response('api.worldweatheronline.com', req_url)
          json_resp = JSON.parse(resp.body)

          total_score = 0
          json_resp["data"]["weather"].each { |w| 
            result_keys = ["date", "precipMM", "tempMinC", "tempMaxC", "weatherCode", "windspeedKmph"]
            result_data = result_keys.collect{|x| w[x]}
            this_score = score_weather(*result_data[1..6])
            total_score += this_score

            date, precip_mm, min_temp, max_temp, weather_code, wind_spd = result_data
            Weather.create!(
              :town_id => town.id,
              :date => date,
              :min_temp => min_temp,
              :max_temp => max_temp,
              :precip_mm => precip_mm,
              :wind_spd => wind_spd,
              :weather_code => weather_code
            )
            puts "Created new weather"
          }

          town.weather_update = Time.now.utc
          town.weather_score = total_score
          town.save
          print "Finished updating #{town.name}"
        end
      rescue Exception => e
        puts e
      end
      sleep 5
    end
  end

  Thread.new do
    puts "Thread started"
    while true do
      begin
        UpdateWeatherJob.new.run
      rescue Exception => e
        puts "Exception: #{e}"
      end
      puts "Done"
    end
  end

end

