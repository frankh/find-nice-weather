class CreateWeathers < ActiveRecord::Migration
  def change
    create_table :weather do |t|
      t.integer :town_id
      t.timestamp :date
      t.integer :min_temp
      t.integer :max_temp
      t.integer :precip_mm
      t.integer :wind_spd
      t.integer :weather_code

      t.timestamps
    end
  end
end
