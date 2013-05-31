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
      #get comments for a ticket by using ticketId and lastcommentId
    end

    def add(params, session)
      #add comments for a ticket by using ticketId
    end


  end
end