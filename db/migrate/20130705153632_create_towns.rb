class CreateTowns < ActiveRecord::Migration
  def change
    create_table :towns do |t|
      t.string :name
      t.string :lng
      t.string :lat
      t.timestamp :weather_update

      t.timestamps
    end
  end
end
