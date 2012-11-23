#!/usr/bin/env ruby

require 'mysql2'
require 'sequel'
require 'sinatra'
require 'haml'
require 'pp'
require 'logger'
require 'yaml'
use Rack::Logger 

module Dirt
  class Application < Sinatra::Application
    CONFIG_FILE = File.join(File.dirname(__FILE__), 'config/config.yml')
    DB_CONFIG_FILE = File.join(File.dirname(__FILE__), 'config/database.yml')

    def self.load_config(file_name)
      env = ENV["RACK_ENV"]
      data = YAML::load(File.open(file_name))[env]
      data.inject({}) { |memo, (k,v)| memo[k.to_sym] = v; memo }
    end

    configure do
      # @config = load_config(CONFIG_FILE)
      db_config = load_config(DB_CONFIG_FILE)

      Dirt::RT_DB = Sequel.connect(db_config[:rt])
      Dirt::RT_DB.loggers << Logger.new($stdout)

      Dirt::DIRT_DB = Sequel.connect(db_config[:dirt])
      Dirt::DIRT_DB.loggers << Logger.new($stdout)

      Dir['models/*.rb'].sort.each { |model| require File.join(File.dirname(__FILE__), model) }
      Dir['controllers/*.rb'].sort.each { |controller| require File.join(File.dirname(__FILE__), controller) }
    end


    get '/:queue' do
      Dirt::CardWallController.show(params)
    end

    get '/projects/:project/' do
      params[:page] = 'index'
      Dirt::PageController.show(params)
    end

    get '/projects/:project/:page' do
      Dirt::PageController.show(params)
    end    

    get '/projects/:project/:page/edit' do
      Dirt::PageController.edit(params)
    end    

    post '/projects/:project/:page/save' do
      Dirt::PageController.save(params)
    end    

    run! if app_file == $0
  end
end

