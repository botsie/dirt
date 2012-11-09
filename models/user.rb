#!/usr/bin/env ruby

require "sequel"

module Dirt
  class User < Sequel::Model(Dirt::RT_DB)
    set_primary_key :id 
    one_to_one :ticket_owner, :class => "Dirt::Ticket", :key => :owner_id
    one_to_one :ticket_creator, :class => "Dirt::Ticket", :key => :creator_id
  end
end