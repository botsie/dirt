#!/usr/bin/env ruby

require 'json'
require 'haml'

module Dirt
  class Macro
    def self.to_html(text)
      data = JSON.load(text)
      type = camel_case(data['type']) + 'Macro'
      Dirt.const_get(type).new(data).to_html
    end

    def self.camel_case(str)
      str.capitalize.gsub(/_(.)/) { |m| $1.upcase }
    end

    def initialize(spec)
      @spec = spec
    end
  end

  class DumpMacro < Macro
    def to_html
      "<notextile> DUMP: " + JSON.dump(@spec) + " </notextile>"
    end
  end

  class TableMacro < Macro
    def to_html
      sql = @spec['sql']
      rows = Dirt::RT_DB[sql].all

      # TODO: Handle the no results case

      headers = rows[1].keys
      
      caption = @spec['caption'] 
      caption ||= ""

      template = %Q{
%h5=caption
%table.table.table-striped.table-bordered
  %tr 
    - headers.each do |header|
      %th=header.to_s
  - rows.each do |row|
    %tr
      - headers.each do |header|
        %td=row[header]
      }

      Haml::Engine.new(template).render(binding)
    end    
  end

end
