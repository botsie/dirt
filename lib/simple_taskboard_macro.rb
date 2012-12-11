#!/usr/bin/env ruby

require 'json'
require 'haml'
require 'chronic'

module Dirt

  class SimpleTaskBoardMacroModel
    def initialize(spec)
      @spec = spec
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

      @streams = Dirt::RT_DB[:expanded_tickets]
                  .select(:id, :Subject)
                  .where(Sequel.lit(where_clause))
                  .all

      return @streams
    end 

    def stream_members(stream_id)
      if stream_id == :all 
        stream_id = streams.collect{|stream| stream[:id]}
      end

      return Dirt::RT_DB[:Links]
              .select(:LocalBase)
              .where(:LocalTarget => stream_id, :Type => 'MemberOf')
    end        

    def cards(args)
      card_selector = @spec['ticket_selector']
      raise "Need a ticket selector to render this macro" if card_selector.nil?

      resolved_after = @spec['resolved_after']

      ds = Dirt::RT_DB[:expanded_tickets]
        .select(:id, :Subject, :Owner, :LastUpdated, :Created)
        .where(lane_column.to_sym => args[:lane])
        .where(Sequel.lit(card_selector))

      if args[:lane] == 'resolved' and not resolved_after.nil?
        first_date = Chronic.parse(resolved_after).strftime('%Y-%m-%d')
        last_date = Date.today.strftime('%Y-%m-%d')

        ds = ds.where(Sequel.lit("Resolved BETWEEN '#{first_date}' AND '#{last_date}'"))
      end

      ds = yield ds

      ds.all.collect do |ticket|
        ticket[:short_subject] = shorten(ticket[:Subject])
        ticket[:age_class] = classify(ticket[:LastUpdated])
        ticket
      end      
    end

    def stream_cards(args)
      stream_id = args[:stream][:id]
      cards(args) {|ds| ds.where(:id => stream_members(stream_id))}
    end

    def misc_cards(args)
      cards(args) {|ds| ds.exclude(:id => stream_members(:all))}
    end

    def shorten(str)
      max_length = 27
      if str.length > max_length
        return str[0..max_length] << "..."
      else
        return str
      end
    end

    def classify(time)
      case Date.today - time.to_date
      when 0..7
        return "this-week"
      when 8..30
        return "this-month"
      else
        return "old"
      end
    end

    def row_class
      @row_class = (@row_class == "even-row") ? "odd-row" : "even-row"
      return @row_class
    end

    def column_class
      @column_class = (@column_class == "even-column") ? "odd-column" : "even-column"
      return @column_class
    end

    def reset_column_class
      @column_class = "even-column"
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
