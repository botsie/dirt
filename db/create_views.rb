#!/usr/bin/env ruby

#
# Quick and dirty script to generate views based on a mapping
#
# Takes mapping json from stdin and prints SQL to stdout
#

require 'json'
require 'erb'
require 'pp'

table_maps = JSON.load($stdin.read)

template = %q{
CREATE OR REPLACE VIEW <%= view_name %> AS
SELECT 
% field_maps[0..-2].each do |map|
%   if map['old_name'] != map['new_name'] then  
  <%= map['old_name'] %> AS <%= map['new_name'] %>,
%   else
  <%= map['old_name'] %>,
%   end  
% end  
% if field_maps.last['old_name'] != field_maps.last['new_name'] then  
  <%= field_maps.last['old_name'] %> AS <%= field_maps.last['new_name'] %>
% else
  <%= field_maps.last['old_name'] %>
% end  
FROM <%= table_name %>;
}

sql = ERB.new(template, 0, "%<>")

# puts table_maps.last.to_s

table_maps.each do |table_map|
  if table_map["create_mapped_view"] then
    view_name = table_map["new_name"]
    table_name = table_map["old_name"]
    field_maps = table_map["field_map"]
    puts sql.result binding
  end
end

expanded_tickets = %Q{
CREATE OR REPLACE VIEW expanded_tickets AS
SELECT 
  Tickets.id AS id,
  Tickets.EffectiveId,
  Tickets.Queue AS queue_id,
  Tickets.Type,
  Tickets.IssueStatement,
  Tickets.Resolution,
  Tickets.Owner AS owner_id,
  Tickets.Subject,
  Tickets.InitialPriority,
  Tickets.FinalPriority,
  Tickets.Priority,
  Tickets.TimeEstimated,
  Tickets.TimeWorked,
  Tickets.Status,
  Tickets.TimeLeft,
  Tickets.Told,
  Tickets.Starts,
  Tickets.Started,
  Tickets.Due,
  Tickets.Resolved,
  Tickets.LastUpdatedBy,
  Tickets.LastUpdated,
  Tickets.Creator AS creator_id,
  Tickets.Created,
  Tickets.Disabled,
  Queues.Name AS Queue,
  Owners.Name AS Owner,
  Creators.Name AS Creator
FROM Tickets, Queues, Users AS Owners, Users AS Creators
WHERE Tickets.Queue = Queues.id
  AND Tickets.Owner = Owners.id
  AND Tickets.Creator = Creators.id;  
}
puts expanded_tickets