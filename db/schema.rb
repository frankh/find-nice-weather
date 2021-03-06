# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20130717133152) do

  create_table "towns", force: true do |t|
    t.string   "name"
    t.string   "lng"
    t.string   "lat"
    t.datetime "weather_update"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "weather_score"
  end

  add_index "towns", ["weather_score"], name: "index_towns_on_weather_score"

  create_table "weather", force: true do |t|
    t.integer  "town_id"
    t.datetime "date"
    t.integer  "min_temp"
    t.integer  "max_temp"
    t.integer  "precip_mm"
    t.integer  "wind_spd"
    t.integer  "weather_code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
