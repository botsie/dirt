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
      when 'comment'
        comment(params)
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

      status = params[:status]
      
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
        Dirt::StatusTicket.where(:ticket_id => params[:ticketId]).update(:status_id => statusId)
        result = Dirt::StatusTicket.where(:ticket_id => params[:ticketId]).first
      end

      # Done with dirt update - update rt db

      # Dirt::Application.http('/ticket/'+params[:ticketId]+"/edit", 'POST', {:Status => statusrow[:rt_status_name]})

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
        row[:pic_url] = @session[:user][:pic_url]
        row[:user_name] = @session[:user_id]
        return row
      end
    end

    def comment(params)
      ticketId = params[:ticketId]
      msg = params[:msg]
      server = Dirt::RT::Server.new(Dirt::CONFIG[:rt_url])
      res = server.addComment(ticketId, msg, @session)

      if res.body.include? "Message recorded"
        return {:status => "600" , :message => "Comment added"}
      else
        return {:status => "602" , :message => "Save failed", :error => res.body}
      end
    end


  end
end