class AddWeatherScoreToTowns < ActiveRecord::Migration
  def change
    add_column :towns, :weather_score, :integer
    add_index :towns, :weather_score
  end
end
