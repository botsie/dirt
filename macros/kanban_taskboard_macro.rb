#!/usr/bin/env ruby

require 'json'
require 'haml'
require 'chronic'

module Dirt

  class KanbanTaskBoardMacroModel
    def initialize(spec)
      @spec = spec
    end

    def caption
      caption = @spec['caption'] 
      caption ||= "Taskboard"
      return caption
    end

    def grp_seq
      @grp_seq = @spec['group_sequence']
      return @grp_seq
    end

    def span
      return @span unless @span.nil?
      grp_seq = @spec['group_sequence']
      @span = Array.new()
      grp_seq.each_index do |row|
        @span << grp_seq[row].length
        grp_seq[row].each_index do |col|
          if grp_seq[row][col].length > 1
            @span[row]+= grp_seq[row][col][1].length-1
          end
        end
        @span[row] = ((12/@span[row]).floor)
      end
      return @span
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

    def cards()
      return @cards unless @cards.nil?

      # Select cards from RT 
      # Select cards from dirt
      # merge both

      # Note: if both are mysql databases linked server can be created and the two queries can be combined


      sql = "SELECT 
                et.id AS id,
                et.Subject AS Subject,
                et.Owner AS Owner,
                et.LastUpdated AS LastUpdated,
                et.Created AS Created,
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

      card_ids = Array.new()
      card_list = ""

      @cards = raw_cards.collect do |ticket|
        card_ids.push(ticket[:id])
        card_list = card_list + "'#{ticket[:id]}' "
        ticket[:short_subject] = shorten(ticket[:Subject])
        ticket[:age_class] = classify(ticket[:LastUpdated])
        ticket
      end

      # have the id's of the cards, we can get the kanban status from dirt db
      # sql = "SELECT * FROM `table_status` AS `ts` LEFT JOIN `statuses` AS `s` ON `ts`.`status_id`=`s`.`id` WHERE `ticket_id` in (#{card_list})"
      # Have find how to do the above sql query using Dirt::DIRT_DB


      # In Rails activerecord 
      TicketStatus.where(:ticket_id => card_ids).joins("LEFT JOIN statuses on `statuses`.`id` = `ticket_status`.`id`")
      # have to do it for sequel


    end
   
  end

  class KanbanTaskBoardMacro < Macro
    def to_html
      # Get IDs of Parent Cards
      model = Dirt::KanbanTaskBoardMacroModel.new(@spec)
      content = haml :kanban_task_board, model     
      return content
    end    
  end

end
