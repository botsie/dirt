#!/usr/bin/env ruby

require "sequel"

module Dirt
  class StatusTicket < Sequel::Model(Dirt::DIRT_DB)
    set_primary_key :id
    many_to_one :statuses

    def self.persist(args = {})
      if args[:id].empty?
        self.insert(:ticket_id => args[:ticket_id], :status_id => args[:status_id])
      else
        self.where(:id => args[:id]).update(:status_id => args[:status_id])
      end
    end


  end 
end
