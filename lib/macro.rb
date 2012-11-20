#!/usr/bin/env ruby

require 'json'
require 'haml'

module Dirt
  class Macro
    def self.to_html(text)
      data = JSON.load(text)
      type = data['type'].capitalize + 'Macro'
      Dirt.const_get(type).new(data).to_html
    end
  end

  class DumpMacro
    def initialize(spec)
      @spec = spec
    end

    def to_html
      "<notextile> DUMP: " + JSON.dump(@spec) + " </notextile>"
    end
  end

  class TableMacro
    def initialize(spec)
      @spec = spec
    end

    def to_html
      sql = @spec['sql']
      rows = Dirt::RT_DB[sql].all
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
