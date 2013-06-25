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




      queues = @spec['queues']
      raise "Need a 'queues' parameter to render this macro" if queues.nil?

      # TODO:
      # Convert this subselect into a join -- may be faster
   
      parent_tickets = Dirt::RT_DB[:Links]
                        .select(:LocalTarget)
                        .where(:Type => 'MemberOf')

      @streams = Dirt::RT_DB[:expanded_tickets]
                  .select(:expanded_tickets__id, 
                    :expanded_tickets__Subject, 
                    :expanded_tickets__Owner, 
                    :expanded_tickets__LastUpdated, 
                    :expanded_tickets__Created)
                  .join(:Links, :expanded_tickets__id => :Links__LocalTarget, :Links__Type => 'MemberOf' )
                  .where(:Queue => queues)
                  .exclude(:Status => ['resolved','deleted'])
                  .distinct
                  .order_by(:expanded_tickets__Subject)
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

      raise "Need a 'queues' parameter to render this macro" if @spec['queues'].nil?
      queues = [*@spec['queues']]

      raise "Need a 'resolved_after' parameter to render this macro" if @spec['resolved_after'].nil?
      resolved_after = @spec['resolved_after']

      first_date = Chronic.parse(resolved_after).strftime('%Y-%m-%d')
      last_date = Chronic.parse("Tomorrow").strftime('%Y-%m-%d')

      p stream_ids

      # Needed to handcraft the SQL to get it right

      sql = "SELECT 
                et.id AS id,
                et.Subject AS Subject,
                et.Owner AS Owner,
                et.LastUpdated AS LastUpdated,
                et.Created AS Created,
                et.#{lane_column()} AS #{lane_column},
                l.LocalTarget AS Parent 
            FROM expanded_tickets et
            LEFT JOIN Links l ON et.id = l.LocalBase AND l.Type = 'MemberOf'
            WHERE et.#{lane_column()} IN('#{lanes.join("', '")}')
              AND ((Resolved BETWEEN '#{first_date}' AND '#{last_date}') OR Status <> 'resolved')"

      if stream_ids.empty?
        sql <<  "AND et.Queue IN('#{queues.join("', '")}')"
      else
        sql <<  "AND (l.LocalTarget IN(#{stream_ids.join(', ')}) 
                    OR et.Queue IN('#{queues.join("', '")}'))"
      end
      sql << " ORDER BY Parent DESC"

      ds = Dirt::RT_DB[sql]

      raw_cards = ds.all

      @cards = raw_cards.collect do |ticket|
        ticket[:short_subject] = shorten(ticket[:Subject])
        ticket[:age_class] = classify(ticket[:LastUpdated])
        ticket
      end      

      return @cards
    end

    def stream_cards(args)
      stream_id = args[:stream][:id]
      lane = args[:lane]
      cards.select do |card| 
        (card[:Parent] == stream_id) and (card[lane_column.to_sym] == lane)
      end
    end

    def misc_cards(args)
      lane = args[:lane]
      lane = args[:lane]
      cards.select do |card| 
        (card[:Parent].nil?) and (card[lane_column.to_sym] == lane) and (not stream_ids.include? card[:id])
      end
    end

    def shorten(str)
      max_length = 27
      if str.length > max_length
        str.insert(14,"- ") if str.index(' ')>14
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
    def to_html(project_name)
      # Get IDs of Parent Cards
      model = Dirt::SimpleTaskBoardMacroModel.new(@spec)
      content = haml :simple_task_board, model     
      return content
    end    
  end

end
