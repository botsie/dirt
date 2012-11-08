#!/usr/bin/env ruby

require 'sequel'
require 'sinatra'
require 'haml'
require 'pp'
require 'logger'

db_user = 'db_admin'
db_password = 'qwedsa123'
db_host = 'smspike.ccaxw0t5omeg.us-east-1.rds.amazonaws.com'
db = 'rt'

DB = Sequel.connect("mysql2://#{db_user}:#{db_password}@#{db_host}/#{db}")
DB.loggers << Logger.new($stdout)

Dir['models/*.rb'].each { |model| require File.join(File.dirname(__FILE__), model) }

get '/:queue' do
  card_wall_controller = CardWallController.new
  card_wall_controller.show(params)
end

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
