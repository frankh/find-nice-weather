class StaticPagesController < ApplicationController
  def home
    @towns = Town.find(:all, :order => "weather_score desc", :limit => 15, :include => 'weather')
  end
end
