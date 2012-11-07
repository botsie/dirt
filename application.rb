#!/usr/bin/env ruby

require 'data_mapper'
require 'sinatra'
require 'haml'
require 'pp'

db_user = 'db_admin'
db_password = 'qwedsa123'
db_host = 'smspike.ccaxw0t5omeg.us-east-1.rds.amazonaws.com'
db = 'rt'

DataMapper::Logger.new($stderr, :debug)
DataMapper.setup(:default, "mysql://#{db_user}:#{db_password}@#{db_host}/#{db}")

Dir['models/*.rb'].each { |model| require File.join(File.dirname(__FILE__), model) }

DataMapper.finalize

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
    # queue = Queue.find(:name => @queue)
    
    @statuses.each do |status|
      @cards[status] = Ticket.all(:queue => {:name => @queue}, :status => status)
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
