# create table towns (
# 	id int not null primary key,
#   name string not null,
#   lng string not null,
#   lat string not null,
#   weather_updated datetime
# )

class Town < ActiveRecord::Base
  has_many :weather,    :dependent => :destroy
end
