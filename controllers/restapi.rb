#!/usr/bin/env ruby

=begin
  
  Respond each request with status code.
  
  600 => Successful, all went fine!
  601 => 'query' missing
  602 => 'query' does not exist
  603 => 'ticketId' missing
  604 => 'commentId' missing
  605 => 'comment_msg' missing
  606 => 'session' does not exist
  607 => save failed
  608 => 'parentId' missing
  609 => 'status' missing



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
        return {:status => "601" , :message => "'query' field is nil"}
      end

      validate(params, session)
      
      case params[:query]
      when 'fetch'
        fetch(params, session)
      when 'update'
        update(params, session)
      when 'add'
        add(params, session)
      else
        return {:status => "602" , :message => "Unknown 'query' field"}
      end
    end

    def validate(params, session)
      if params[:ticketId].nil?
        return {:status => "603" , :message => "'ticketId' cannot be nil"}
      elsif session.nil?
        return {:status => "606" , :message => "'session' does not exist"}
      end
    end

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

    def status(params,session)
      #change status of a ticket using ticketId
      #sets new parentId and status
      if params[:parentId].nil?
        return {:status => "608" , :message => "'parentId' cannot be nil"}
      end
      if params[:status].nil?
        return {:status => "609" , :message => "'status' cannot be nil"}
      end
      
    end

  end
end