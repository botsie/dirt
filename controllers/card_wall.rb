#!/usr/bin/env ruby

module Dirt
  class CardWallController < Dirt::Controller
    def show(params, session)
      @cards = Hash.new
      @queue = params[:queue]
      @statuses = [ 'new', 'open', 'stalled', 'resolved' ]
      # @results = Ticket.all(:queue => @queue, :status => @statuses)
      queue = Dirt::Queue[:name => @queue]

      @statuses.each do |status|
        @cards[status] = Dirt::Ticket.eager_graph(:owner).where(:status => status, :queue => queue).all
        # @cards[status] = queue.ticket(:status => status)
      end
      haml :card_wall
    end
  end
end