#!/usr/bin/env ruby

require "data_mapper"

class Ticket
  include DataMapper::Resource

  property :id,         Serial
  property :subject,    String

  belongs_to :queue
end