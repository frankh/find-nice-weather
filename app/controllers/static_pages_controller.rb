class StaticPagesController < ApplicationController
  def home
    @towns = Town.find(:all, :order => "weather_score asc", :limit => 15, :include => 'weather')
  end
end
