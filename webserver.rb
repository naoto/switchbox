#!/usr/bin/env ruby

require 'rubygems'
require 'sqlite3'
require 'sinatra'
require 'json'
require 'gruff'
require 'date'

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

get '/graph' do
  
  keys =  [:temperature, :humidity, :co2]

  unless params[:device_id]
    status 400
    return { error: 'device_id is required' }.to_json
  end

  unless params[:target] || keys.include?(params[:target].to_sym)
    status 400
    return { error: 'target is required' }.to_json
  end

  content_type 'image/png'

  @db = SQLite3::Database.new DB_PATH
  today_start = Time.now.strftime('%Y-%m-%d 00:00:00')

  records = @db.execute(
    "SELECT #{params[:target]}, created_at FROM device_status WHERE device_id = ? AND created_at >= ? ORDER BY id ASC",
    [params[:device_id], today_start]
  )

  g = Gruff::Line.new
  g.title = 'House Metrics'
  g.data params[:target].to_sym, records.map { |r| r[0] }
  g.labels = records.each_with_index.map { |r, i| [i, r[1][11, 5]] if i % 20 == 0 }.compact.to_h

  temp_file = "#{params[:target]}.png"
  g.write(temp_file)

  send_file temp_file, type: 'image/png'
end
