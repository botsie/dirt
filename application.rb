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

  class CardWallController
    def show(params)
      @cards = Hash.new
      @queue = params[:queue]
      @statuses = [ 'new', 'open', 'stalled', 'resolved' ]
      # @results = Ticket.all(:queue => @queue, :status => @statuses)
      queue = Dirt::Queue[:name => @queue]

      @statuses.each do |status|
        @cards[status] = Dirt::Ticket.where(:status => status, :queue => queue)
        # @cards[status] = queue.ticket(:status => status)
      end

      haml :card_wall
    end

    def haml( template_id )
      layout = File.read('views/layout.haml')
      template = File.read('views/' + template_id.to_s + '.haml')
      layout_engine = Haml::Engine.new(layout)
      layout_engine.render(self) do
        template_engine = Haml::Engine.new(template)
        template_engine.render(self)
      end
    end
  end

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

      Dir['models/*.rb'].each { |model| require File.join(File.dirname(__FILE__), model) }
    end


    get '/:queue' do
      card_wall_controller = Dirt::CardWallController.new
      card_wall_controller.show(params)
    end

    run! if app_file == $0
  end

end

