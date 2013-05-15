#!/usr/bin/env ruby

module Dirt

  class TicketController < Dirt::Controller
    def self.process(params, session)
    end

    def fetchTicketInfo
    end

    def addComment
    end

    def delComment
    end

    def editComment
    end

    def editTicket
      #edit can change status, ticket name, description etc
    end

    def getComment
      #do long poll - have to think abt it.
    end
  end
end