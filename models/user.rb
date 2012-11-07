#!/usr/bin/env ruby

require "data_mapper"

class Ticket
  include DataMapper::Resource

  property :id,         Serial
  property :name,       String

end