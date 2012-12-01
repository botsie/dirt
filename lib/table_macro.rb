#!/usr/bin/env ruby

require 'json'
require 'haml'
require 'chronic'

module Dirt

  class TableMacro < Macro
    def to_html
      sql = @spec['sql']
      rows = Dirt::RT_DB[sql].all

      # TODO: Handle the no results case

      headers = rows.first.keys
      
      caption = @spec['caption'] 
      caption ||= ""

      template = %Q{
%h5=caption
%table.table.table-striped.table-bordered
  %tr 
    - headers.each do |header|
      %th=header.to_s.gsub(/_/," ").capitalize
  - rows.each do |row|
    %tr
      - headers.each do |header|
        %td=row[header]
      }

      Haml::Engine.new(template).render(binding)
    end    
  end

end
