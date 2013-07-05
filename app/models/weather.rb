# create table weather (
# 	id int not null primary key,
#   town_id int not null,
#   date datetime not null,
#   min_temp int,
#   max_temp int,
#   precip_mm int,
#   wind_spd int,
#   weather_code int
# )

class Weather < ActiveRecord::Base
	self.table_name = "weather"

	belongs_to :town

	default_scope :order => 'weather.date ASC'
end
