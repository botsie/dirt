#!/usr/bin/env ruby

module Dirt
  class ProjectApiModel
    def cards(project_identifier)
      return @cards unless @cards.nil?

      # Select cards from RT 
      # Select cards from dirt
      # merge both

      # Note: if both are mysql databases linked server can be created and the two queries can be combined

      project = Dirt::Project.where(:identifier => project_identifier).first

      if project[:taskboard] == "" || project[:taskboard].nil?
        # raise an error here
        return
      end
      begin
        spec = JSON.load(project[:taskboard])
      rescue JSON::ParserError => error
        # raise an error here
        return
      end
      spec[:project_id] = project[:id]


      raise "Need a 'queues' parameter to render this macro" if spec['queues'].nil?
      queues = [*spec['queues']]

      raise "Need a 'resolved_after' parameter to render this macro" if spec['resolved_after'].nil?
      resolved_after = spec['resolved_after']

      first_date = Chronic.parse(resolved_after).strftime('%Y-%m-%d')
      last_date = Chronic.parse("Tomorrow").strftime('%Y-%m-%d')

      sql = "SELECT DISTINCT
                id, 
                Subject, 
                Owner, 
                LastUpdated, 
                Created, 
                Status 
            FROM expanded_tickets
            WHERE Status IN('new', 'open', 'stalled', 'resolved')
              AND ((Resolved BETWEEN '#{first_date}' AND '#{last_date}') OR Status <> 'resolved')
              AND Queue IN('#{queues.join("', '")}')
              ORDER BY id"

      ds = Dirt::RT_DB[sql]

      raw_cards = ds.all

      card_ids = Array.new()
      card_list = ""

      # done with retreiving cards

      @cards = raw_cards.collect do |ticket|
        card_ids.push(ticket[:id])
        ticket[:short_subject] = shorten(ticket[:Subject])
        ticket[:age_class] = classify(ticket[:LastUpdated])
        ticket[:origin] = origin(ticket[:id])
        ticket
      end

      # find all the statuses for the current project
      # have the id's of the cards, we can get the kanban status from dirt db
      # sql = "SELECT * FROM `status_tickets` AS `ts` LEFT JOIN `statuses` AS `s` ON `ts`.`status_id`=`s`.`id` WHERE `ticket_id` in (#{card_list})"
      # Have find how to do the above sql query using Dirt::DIRT_DB


      ticket_status = Dirt::StatusTicket.where(:ticket_id => card_ids).left_join(:statuses, :id => :status_id).where(:project_id => spec[:project_id]).order(:ticket_id).all

      if ticket_status.length != @cards.length
        @unclassified_present = true
      else
        @unclassified_present = false
      end

      i = 0
      ticket_status.each do |value|
        while (@cards[i][:id] < value[:ticket_id]) do
          i += 1
        end

        if @cards[i][:id] == value[:ticket_id]
          @cards[i].merge!({:status_id => value[:status_id], :kanban_status => value[:status_name], :project_id => value[:project_id]})
        end
      end
      return @cards
    end

    def statuses(project_identifier)
    end

    def origin(id)
      "#{Dirt::CONFIG[:rt_url]}/Ticket/Display.html?id=#{id}"
    end

    def shorten(str)
      max_length = 50
      if str.length > max_length
        # str.insert(14,"- ") if str.index(' ')>14 || str.index(' ')<7 
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

  end
end

