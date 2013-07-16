#!/usr/bin/env ruby

require 'json'
require 'haml'
require 'chronic'

module Dirt
  class NotepadController < Dirt::Controller
    def show(params)
      @queues = Dirt::RT_DB[:queues].select(:name).distinct.all
      @project = params[:project]
      @error_msg = params[:error_msg]
      @success_msg = params[:success_msg]
      @tab_spec = Dirt::PageController.new(session).get_tab_spec(@project,"../notepad")
      p @session
      haml :notepad
    end

    def self.processNotepad(params, session)
      error_msg = Array.new
      success_msg = Array.new
      infotext = params[:notepad_text];
      queue = params[:queue_name]

      parent = nil
      child = nil
      grandchild = nil
      ticketId = nil
      
      rt_server = Dirt::RT::Server.new(Dirt::CONFIG[:rt_url])
      
      if infotext==""
        error_msg.push('Notes not found')
      end
      
      infotext.each_line do |line|
        line.gsub!(/^(\**)\s?([a-zA-Z0-9\$%_\*\+\s\.]*)\s?(@([a-zA-Z0-9_\.]*))?/) do |match|
          heir = $1
          ticket_subject = $2
          owner = $4

          if heir=="" && ticket_subject==""
            break
          end

          ticketId = nil

          # its a ticket
          if ticket_subject.nil?
            error_msg.push('Ticket subject not found - syntax error - ticket ignored')
          elsif heir.nil?
            error_msg.push('Ticket heirarchy not defined - syntax error - ticket ignored')
          else
            response = rt_server.createTicket(ticket_subject, session, queue, owner)
            
            response.body.gsub!(/^#\sTicket\s([0-9]*)\screated./) do
              ticketId = $1
            end

            success_msg.push('Ticket created successfully - Ticket Id #'+ ticketId)
            
            case heir.length.to_s
            when "1"
              # parent ticket
              parent = ticketId
            when "2"
              # child ticket
              child = ticketId
              if parent.nil?
                error_msg.push('Parent Ticket not set - syntax error - #'+ticketId+' does not have a parent')
              else
                success_msg.push('#'+ticketId+' added as a child to #'+ parent)
                response = rt_server.addParent(child, parent, session)
              end
            when "3"
              # grandchild ticket
              grandchild = ticketId
              if parent.nil?
                error_msg.push('Child Ticket not set - syntax error - #'+ticketId+' does not have a parent')
              else
                success_msg.push('#'+ticketId+' added as a child to #'+ child)
                response = rt_server.addParent(grandchild, child, session)
              end
            end
          end
        end

        line.gsub!(/^\s?(-)\s?([a-zA-Z0-9\$%_\*\+\s\.]*)/) do |match|
          #its a comment
          text = $2
          if ticketId.nil?
            error_msg.push('Parent ticket not defined or was not created- syntax error - comment ignored')      
          else
            success_msg.push('Comment added to ticket #' + ticketId)
            rt_server.addComment(ticketId, text, session)
          end
        end
      end

      msg = {:error_msg => error_msg, :success_msg => success_msg}
      return msg
    end

  end
end
