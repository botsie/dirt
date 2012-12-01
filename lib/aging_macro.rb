#!/usr/bin/env ruby

require 'json'
require 'haml'
require 'chronic'

module Dirt
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
