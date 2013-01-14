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
      return lane_column.to_sym
    end

    def span
      return @span unless @span.nil?
      width = (12 / (lanes.count + 1 )).floor
      @span = "span" + width.to_s
      return @span
    end

    def streams
      return @streams unless @streams.nil?

      queues = @spec['queues']
      raise "Need a 'queues' parameter to render this macro" if queues.nil?

      # TODO:
      # Convert this subselect into a join -- may be faster
   
      parent_tickets = Dirt::RT_DB[:Links]
                        .select(:LocalTarget)
                        .where(:Type => 'MemberOf')

      @streams = Dirt::RT_DB[:expanded_tickets]
                  .select(:id, :Subject, :Owner, :LastUpdated, :Created)
                  .where(:Queue => queues)
                  .where(:id => parent_tickets)
                  .exclude(:Status => ['resolved','deleted'])
                  .all

      return @streams
    end 

    def stream_ids
      return @stream_ids unless @stream_ids.nil?

      @stream_ids = streams.collect{|stream| stream[:id]}

      return @stream_ids
    end

    def stream_members(stream_id)
      if stream_id == :all 
        stream_id = stream_ids
      end

      return Dirt::RT_DB[:Links]
              .select(:LocalBase)
              .where(:LocalTarget => stream_id, :Type => 'MemberOf')
    end    

    def cards
      return @cards unless @cards.nil?

      # SELECT l.LocalBase AS Parent, et.*
      # FROM expanded_tickets et
      # LEFT JOIN Links l ON et.id = l.LocalBase and l.Type = 'MemberOf'
      # WHERE et.Status IN('open','new')
      #  AND (l.LocalTarget IN(1185289, 1208515, 1141057, 1141109, 1209731) OR et.Queue = 'linux-hosting')
      # ORDER BY Parent DESC

      queues = @spec['queues']
      raise "Need a 'queues' parameter to render this macro" if queues.nil?

      # resolved_after = @spec['resolved_after']

      ds = Dirt::RT_DB[:expanded_tickets]
        .select(:expanded_tickets__id, 
                :expanded_tickets__Subject,
                :expanded_tickets__Owner, 
                :expanded_tickets__LastUpdated, 
                :expanded_tickets__Created, 
                lane_column(), 
                :Links__LocalBase___Parent)
        .left_outer_join(:Links, :expanded_tickets__id => :Links__LocalBase, :Links__Type => 'MemberOf')
        .where(lane_column => lanes)
        .filter(:Links__LocalTarget => stream_ids).or(:Queue => queues)
        .reverse_order(:Parent)
        

      # if args[:lane] == 'resolved' and not resolved_after.nil?
      #   first_date = Chronic.parse(resolved_after).strftime('%Y-%m-%d')
      #   last_date = Chronic.parse("Tomorrow").strftime('%Y-%m-%d')

      #   ds = ds.where(Sequel.lit("Resolved BETWEEN '#{first_date}' AND '#{last_date}'"))
      # end

      # ds = yield ds

      @cards = ds.all.collect do |ticket|
        ticket[:short_subject] = shorten(ticket[:Subject])
        ticket[:age_class] = classify(ticket[:LastUpdated])
        ticket
      end      

      return @cards
    end

    def stream_cards(args)
      stream_id = args[:stream][:id]
      lane = args[:lane]
      cards.select {|card| (card[:Parent] == stream_id) && (card[lane_column] == lane)}
    end

    def misc_cards(args)
      lane = args[:lane]
      cards.select {|card| (card[:Parent].nil?) && (card[lane_column] == lane)}
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
      content = haml :simple_task_board, model     
      return content
    end    
  end

end
