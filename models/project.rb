#!/usr/bin/env ruby

require "sequel"

module Dirt
  class Project < Sequel::Model(Dirt::DIRT_DB)
    set_primary_key :id
    one_to_many :pages
  end	
end
