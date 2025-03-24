#!/usr/bin/env ruby

require 'rubygems'
require 'sqlite3'
require 'sinatra'
require 'json'

BASE_DIR = File.expand_path(__dir__)
DB_PATH = File.join(BASE_DIR, 'database', 'switchbot.db')

get '/' do
  content_type :json

  @db = SQLite3::Database.new DB_PATH
  records = @db.execute('SELECT battery, temperature, humidity, co2, created_at  FROM device_status WHERE device_id = ? ORDER BY id desc limit 1', params[:device_id])
  
  if records.any?
    record = records.first
    {
      battery: record[0],
      temperature: record[1],
      humidity: record[2],
      co2: record[3],
      created_at: record[4]
    }.to_json
  else
    status 404
    { error: 'Record Not Found' }.to_json
  end
end
