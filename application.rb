#!/usr/bin/env ruby

require 'data_mapper'

db_user = 'db_admin'
db_password = 'qwedsa123'
db_host = 'smspike.ccaxw0t5omeg.us-east-1.rds.amazonaws.com'
db = 'rt'

DataMapper::Logger.new($stderr, :debug)
DataMapper.setup(:default, "mysql://#{db_user}:#{db_password}@#{db_host}/#{db}")

repository(:default).adapter.resource_naming_convention = lambda do |value|
  puts value
  DataMapper::Inflector.titleize(DataMapper::Inflector.pluralize(value))
end

repository(:default).adapter.field_naming_convention = lambda do |value|
  puts value.name
  if value.name.to_s == 'id' then
    puts "===="
    'id'
  else
    DataMapper::Inflector.camelize(value.name)
  end 
end


Dir['models/*.rb'].each { |model| require File.join(File.dirname(__FILE__), model) }

DataMapper.finalize

# tickets = Ticket.all(:queue => { :name => 'dcbox' })
# tickets = Ticket.all(:queue => 71)
tickets = Ticket.count(:queue => Queue.all(:name => 'dcbox'))

# puts tickets

tickets.each do |t|
  puts "#{t.id} | {t.queue} | #{t.subject}"
  # p t
end
