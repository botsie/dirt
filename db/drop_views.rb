#!/usr/bin/env ruby

#
# Quick and dirty script to drop views based on a mapping
#
# Takes mapping json from stdin and prints SQL to stdout
#

require 'json'
require 'erb'
require 'pp'

table_maps = JSON.load($stdin.read)

template = %q{
% maps = table_maps.select { |t| t["create_mapped_view"] }
DROP VIEW IF EXISTS
% maps[0..-2].each do |map| 
  <%= map['new_name'] %>,
% end  
  <%= maps.last['new_name'] %> 
}

puts ERB.new(template, 0, "%<>").result binding
