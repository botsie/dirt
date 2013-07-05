#!/usr/bin/env ruby

require 'json'
require 'haml'
require 'chronic'

module Dirt
  class NotepadController < Dirt::Controller
    def show(params)
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

      parent = nil
      child = nil
      grandchild = nil
      
      rt_server = Dirt::RT::Server.new(Dirt::CONFIG[:rt_url])
      
      if infotext==""
        error_msg.push('Notes not found')
      end
      
      infotext.each_line do |line|
        line.gsub!(/^(\**)\s?(-)?\s?([a-zA-Z0-9\$%_\*\+\s\.]*)\s?-?\s?([a-zA-Z0-9\$%_\*\+\s\.]*)?/) do |match|
          # * ticket_subject - Ticket_Content
          # *-comment_text
          heir = $1
          iscomment = $2
          comment_subject = $3
          text = $4


          if not iscomment.nil?
            # its a comment
            case $1.length.to_i
              when 1
                # comment - parent ticket
                if parent.nil?
                  error_msg.push('Parent ticket not defined - syntax error - comment ignored')
                elsif comment_subject.nil?
                  error_msg.push('Comment text not found - syntax error - comment ignored')
                else
                  success_msg.push('Comment added to ticket #' + parent)
                  rt_server.addComment(parent, comment_subject, session)
                end
              when 2
                # comment - child ticket
                if child.nil?
                  error_msg.push('Child ticket not defined - syntax error - comment ignored')
                elsif comment_subject.nil?
                  error_msg.push('Comment text not found - syntax error - comment ignored')
                else
                  success_msg.push('Comment added to ticket #' +child)
                  rt_server.addComment(child, comment_subject, session)
                end
              when 3
                # comment - grandchild ticket
                if grandchild.nil?
                  error_msg.push('Grandchild ticket not defined - syntax error - comment ignored')
                elsif comment_subject.nil?
                  error_msg.push('Comment text not found - syntax error - comment ignored')
                else
                  success_msg.push('Comment added to ticket #' + grandchild)
                  rt_server.addComment(grandchild, comment_subject, session)
                end
            end
            #End of comment processing
          else 
            # its a ticket
            if comment_subject.nil?
              error_msg.push('Ticket subject not found - syntax error - ticket ignored')
            elsif text.nil?
              error_msg.push('Ticket text not found - syntax error - ticket ignored')
            elsif heir.nil? || heir.length==0
              error_msg.push('Ticket heirarchy not defined - syntax error - ticket ignored')
            else
              response = rt_server.createTicket(comment_subject, text, session)
              ticketId = ""
              
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

        end
      end
      msg = {:error_msg => error_msg, :success_msg => success_msg}
      return msg
    end

  end
end
