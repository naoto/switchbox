#!/usr/bin/env ruby

require 'rubygems'
require 'sqlite3'
require 'switchbot'
require 'dotenv/load'

BASE_DIR = File.expand_path('..', __dir__)
DB_PATH = File.join(BASE_DIR, 'database', 'switchbot.db')

def init_database
  @db = SQLite3::Database.new DB_PATH

  @db.execute <<-SQL
    CREATE TABLE IF NOT EXISTS devices (
      id INTEGER PRIMARY KEY,
      device_id TEXT,
      name TEXT,
      type TEXT
    );
  SQL

  @db.execute <<-SQL
    CREATE TABLE IF NOT EXISTS device_status (
      id INTEGER PRIMARY KEY,
      device_id TEXT,
      temperature REAL,
      battery REAL,
      humidity REAL,
      co2 REAL,
      created_at TIMESTAMP DEFAULT (DATETIME('now', 'localtime')),
      updated_at TIMESTAMP DEFAULT (DATETIME('now', 'localtime'))
    );
  SQL
end

def save_device(device)
  record = @db.execute('SELECT id FROM devices WHERE device_id = ?', device[:device_id])
  return if record.length > 0

  @db.execute('INSERT INTO devices (device_id, name, type) VALUES (?, ?, ?)', [device[:device_id], device[:device_name], device[:device_type]])
end

def save_device_status(device_id, status)
  @db.execute('INSERT INTO device_status (device_id, temperature, battery, humidity, co2) VALUES (?, ?, ?, ?, ?)', [device_id, status[:temperature], status[:battery], status[:humidity], status[:co2]])
end

def fetch_device
  client = Switchbot::Client.new(@switchbot_token, @switchbot_secret)
  res = client.devices

  if res[:status_code] == 100
    res[:body][:device_list].each do |device|
      save_device(device)
    end
  end
end

def fetch_device_status
  @db.execute('SELECT device_id FROM devices').each do |device|
    client = Switchbot::Client.new(@switchbot_token, @switchbot_secret)
    res = client.device(device[0]).status

    if res[:status_code] == 100
      save_device_status(device[0], res[:body])
    end
  end
end

def run
  init_database

  fetch_device if Time.now.min == 0 # 時刻が0分の場合のみデバイスを取得
  fetch_device_status
end


@switchbot_token = ENV['SWITCHBOT_TOKEN']
@switchbot_secret = ENV['SWITCHBOT_SECRET']

run