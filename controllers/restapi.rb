#!/usr/bin/env ruby

=begin
  
  Respond each request with status code.
  
  600 => Successful, all went fine!
  601 => 'query' invalid
  602 => save failed
  603 => 'ticketId' missing
  604 => query yielded an empty set
  605 => 'comment_msg' missing
  606 => 'session' does not exist
  607 => 'projectId' missing
  608 => 'status' missing
  609 => 'commentId' missing



  methods :
  fetch - to fetch the comments for a ticket
  update - check for updates for a ticket
  add - add a comment for a ticket
  status - change status of a ticket
  info - gets information about a ticket from rt
=end

module Dirt

  class RestapiController < Dirt::Controller
    def show(params)
      #respond to query variable
      if params[:query].nil?
        return {:status => "601" , :message => "Invalid 'query' field"}
      elsif params[:ticketId].nil?
        return {:status => "603" , :message => "'ticketId' cannot be nil"}
      elsif @session.nil?
        return {:status => "606" , :message => "'session' does not exist"}
      end

      
      case params[:query]

      when 'status'
        status(params)
      when 'info'
        info(params)
      else
        return {:status => "601" , :message => "Invalid 'query' field"}
      end
    end

    def status(params)
      #change status of a ticket using ticketId
      #sets new statusId and status
      if params[:projectId].nil?
        return {:status => "607" , :message => "'projectId' cannot be nil"}
      end
      if params[:status].nil?
        return {:status => "608" , :message => "'status' cannot be nil"}
      end

      status = params[:status].downcase
      
      statusrow = Dirt::Status.where(:status_name => status, :project_id => params[:projectId]).first
      
      if statusrow.nil?
        Dirt::Status.insert(:status_name => status, :project_id => params[:projectId], :rt_status_id => 2, :max_tickets => 0)
        statusrow = Dirt::Status.where(:status_name => status, :project_id => params[:projectId]).first
      end
      
      statusId = statusrow[:id]

      row =  Dirt::StatusTicket.where(:ticket_id => params[:ticketId]).first

      if row.nil?
        result = Dirt::StatusTicket.insert(:ticket_id => params[:ticketId], :status_id => statusId)
      else
        result = row.update(:status_id => statusId)
      end

      if result.nil?
        return {:status => "601" , :message => "Save failed"}
      else
        return {:status => "600" , :message => "Updated successfully"}
      end
    end

    def info(params)
      ticketId = params[:ticketId]

      row = Dirt::RT_DB[:expanded_tickets].where(:id => ticketId).first

      if row.nil?
        return {:status => "604" , :message => "Query yielded an empyt set"}
      else 
        return row
      end
    end

  end
end