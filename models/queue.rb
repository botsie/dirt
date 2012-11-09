#!/usr/bin/env ruby

require "sequel"

module Dirt
  class Queue < Sequel::Model(Dirt::RT_DB)
    set_primary_key :id
    one_to_many :tickets
  end
end