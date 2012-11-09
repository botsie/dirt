#!/usr/bin/env ruby

require "sequel"

module Dirt
  class Ticket < Sequel::Model(Dirt::RT_DB)
    set_primary_key :id
    many_to_one :queue
    many_to_one :owner, :class => "Dirt::User"
    many_to_one :creator, :class => "Dirt::User"
  end	
end
