#!/usr/bin/env ruby

=begin
  
  Respond each request with status code.
  
  600 => Successful, all went fine!
  601 => 'query' invalid
  602 => save failed
  603 => 'ticketId' missing
  604 => 'commentId' missing
  605 => 'comment_msg' missing
  606 => 'session' does not exist
  607 => 'projectId' missing
  608 => 'status' missing



  methods :
  fetch - to fetch the comments for a ticket
  update - check for updates for a ticket
  add - add a comment for a ticket
  status - change status of a ticket
=end

module Dirt

  class RestapiController < Dirt::Controller
    def show(params, session)
      #respond to query variable
      if params[:query].nil?
        return {:status => "601" , :message => "Invalid 'query' field"}
      elsif params[:ticketId].nil?
        return {:status => "603" , :message => "'ticketId' cannot be nil"}
      elsif session.nil?
        return {:status => "606" , :message => "'session' does not exist"}
      end

      
      case params[:query]
=begin   
      when 'fetch'
        fetch(params, session)
      when 'update'
        update(params, session)
      when 'add'
        add(params, session)
=end
      when 'status'
        status(params, session)
      else
        return {:status => "601" , :message => "Invalid 'query' field"}
      end
    end

=begin
    def fetch(params, session)
      #get comments for a ticket by using ticketId

    end

    def update(params, session)
      #get comments for a ticket by using ticketId and last commentId
      if params[:commentId].nil?
        return {:status => "604" , :message => "'commentId' cannot be nil"}
      end

    end

    def add(params, session)
      #add comments for a ticket by using ticketId
      if params[:comment_msg].nil?
        return {:status => "605" , :message => "'comment_msg' cannot be nil"}
      end
      msg = params[:comment_msg].to_s
    end
=end
    def status(params,session)
      #change status of a ticket using ticketId
      #sets new statusId and status
      if params[:projectId].nil?
        return {:status => "607" , :message => "'projectId' cannot be nil"}
      end
      if params[:status].nil?
        return {:status => "608" , :message => "'status' cannot be nil"}
      end
      
      statusrow = Dirt::Status.where(:status_name => params[:status], :project_id => params[:projectId]).first

      if statusrow.nil?
        Dirt::Status.insert(:status_name => params[:status], :project_id => params[:projectId])
      end
        statusId = statusrow[:id]

      result =  Dirt::StatusTicket.where(:ticket_id => params[:ticketId]).update(:status_id => statusId)

      if result
        return {:status => "600" , :message => "Updated successfully"}
      else
        return {:status => "601" , :message => "Save failed"}
      end
    end

  end
end