#!/usr/bin/env ruby

require "sequel"

module Dirt
  class Page < Sequel::Model(Dirt::DIRT_DB)
    set_primary_key :id
    many_to_one :project
  end	
end
