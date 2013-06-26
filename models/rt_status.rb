#!/usr/bin/env ruby

require "sequel"

module Dirt
  class RtStatus < Sequel::Model(Dirt::DIRT_DB)
    set_primary_key :id
    one_to_many :statuses

    def self.persist(args = {})
    end
  end 
end
