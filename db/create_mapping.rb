#!/usr/bin/env ruby

require 'mysql2'
require 'yaml'
require 'json'

#
# Quick and dirty script to generate mapping from legacy names to new names
#

db_user = 'db_admin'
db_password = 'qwedsa123'
db_host = 'smspike.ccaxw0t5omeg.us-east-1.rds.amazonaws.com'
db = 'rt'

class String
  def snake_case
    self.gsub(/[A-Z]/, '_\0').downcase.gsub(/^_/,'')
  end
end

client = Mysql2::Client.new(:host => db_host, :username => db_user, :password => db_password, :database => db)
client.query_options.merge!(:symbolize_keys => true)

table_maps = Array.new

client.query('SHOW FULL TABLES').each do |table|
  if table[:Table_type] == 'BASE TABLE' then
    table_map = Hash.new
    table_map[:old_name] = table["Tables_in_#{db}".to_sym]
    table_map[:new_name] = table_map[:old_name].snake_case
    table_map[:create_mapped_view] = false

    field_maps = Array.new
    client.query("SHOW COLUMNS FROM #{table_map[:old_name]}").each do |column|
      field_map = Hash.new 
      field_map[:old_name] = column[:Field]
      field_map[:new_name] = column[:Field].snake_case
      field_maps << field_map
    end

    table_map[:field_map] = field_maps
    table_maps << table_map
  end
end

# puts table_maps.to_yaml
puts JSON.pretty_generate table_maps
