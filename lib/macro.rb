#!/usr/bin/env ruby

require 'json'
require 'haml'
require 'chronic'

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
      @spec = expand_sql(@spec)
    end

    def expand_sql(spec)
      if spec.has_key? 'sql' then
        spec['sql'].gsub!(/%([A-Z0-9_]+)\((.*?)\)/) do |match_string|
          function_name = $1.downcase
          params = $2
          self.method(function_name.to_sym).call(params)
        end
      end
      return spec
    end

    def date(date_string)
      Chronic.parse(date_string).strftime(%q{'%Y-%m-%d'})
    end

    def avg_days_since(field_name)
      "CAST(ROUND(AVG(DATEDIFF(CURRENT_DATE(),DATE(#{field_name}))),0) AS SIGNED) AS AVG_DAYS_SINCE_#{field_name.upcase}"
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

  class AgingMacro < Macro
    def to_html
      queues = @spec['queues']
      last_week = Dirt::RT_DB[:expanded_tickets]
                    .where(:Created => Chronic.parse("last week")..Chronic.parse("today"), 
                            :Status => ['new', 'open', 'stalled'],
                            :Queue => queues)
                    .count

      last_month = Dirt::RT_DB[:expanded_tickets]
                    .where(:Created => Chronic.parse("last month")..Chronic.parse("last week"), 
                            :Status => ['new', 'open', 'stalled'],
                            :Queue => queues)
                    .count

      last_quarter = Dirt::RT_DB[:expanded_tickets]
                    .where(:Created => Chronic.parse("3 months ago")..Chronic.parse("last month"), 
                            :Status => ['new', 'open', 'stalled'],
                            :Queue => queues)
                    .count

      before_last_quarter = Dirt::RT_DB[:expanded_tickets]
                              .where(:Status => ['new', 'open', 'stalled'],
                                      :Queue => queues)
                              .where(Sequel.expr(:Created) < Chronic.parse('3 months ago'))
                              .count

      caption = @spec['caption']

      template = %Q{
%h5=caption
%table.table.table-striped.table-bordered
  %tr
    %th="Age"
    %th="Count"
  %tr
    %td="Less than 1 week"
    %td=last_week
  %tr
    %td="Less than 1 month"
    %td=last_month
  %tr
    %td="Less than 1 quarter"
    %td=last_quarter
  %tr
    %td="More than 1 quarter"
    %td=before_last_quarter
      }

      Haml::Engine.new(template).render(binding)
    end
  end

end
