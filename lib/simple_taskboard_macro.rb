#!/usr/bin/env ruby

require 'json'
require 'haml'
require 'chronic'

module Dirt

  class SimpleTaskBoardMacroModel
    def initialize(spec)
      @spec = spec
      p @spec
    end

    def caption
      caption = @spec['caption'] 
      caption ||= "Taskboard"
      return caption
    end      
    
    def lanes
      lanes = @spec['group_sequence'] 
      lanes ||= ['new', 'open', 'stalled', 'resolved']
      return lanes
    end

    def lane_column
      lane_column = @spec['group_by'] 
      lane_column ||= 'Status'
      return lane_column
    end

    def span
      return @span unless @span.nil?
      width = (12 / (lanes.count + 1 )).floor
      @span = "span" + width.to_s
      return @span
    end

    def streams
      return @streams unless @streams.nil?

      where_clause = @spec['workstream_selector']
      raise "Need a Workstream selector to render this macro" if where_clause.nil?

#      sql = %Q{SELECT id, Subject FROM expanded_tickets WHERE ?}
#      @streams = Dirt::RT_DB.fetch(sql, where_clause)

      @streams = Dirt::RT_DB[:expanded_tickets]
                  .select(:id, :Subject)
                  .where(Sequel.lit(where_clause))
                  .all

      return @streams
    end 

    def cards(args)
      card_selector = @spec['ticket_selector']
      raise "Need a ticket selector to render this macro" if card_selector.nil?

      child_ids = Dirt::RT_DB[:Links]
                    .select(:LocalBase)
                    .where(:LocalTarget => args[:stream][:id], :Type => 'MemberOf')

      Dirt::RT_DB[:expanded_tickets]
        .select(:id, :Subject, :Owner)
        .where(:id => child_ids)
        .where(lane_column.to_sym => args[:lane])
        .where(Sequel.lit(card_selector))
        .all
    end

    def row_class
      @row_class = (@row_class == "even-stream") ? "odd-stream" : "even-stream"
      return @row_class
    end
  end

  class SimpleTaskBoardMacro < Macro
    def to_html
      # Get IDs of Parent Cards
      model = Dirt::SimpleTaskBoardMacroModel.new(@spec)
      haml :simple_task_board, model      
    end    
  end

end
