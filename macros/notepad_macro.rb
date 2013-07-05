#!/usr/bin/env ruby

require 'json'
require 'haml'
require 'chronic'

module Dirt

  class NotepadMacroModel
    def initialize(spec)
      @spec = spec
    end

    def caption
      return @spec['caption'] || "Notepad"
    end

  end

  class NotepadMacro < Macro
    def to_html(project_name)
      # Get IDs of Parent Cards
      model = Dirt::NotepadMacroModel.new(@spec)
      content = haml :notepad, model     
      return content
    end    

    def self.processNotepad(params, session)
      
      infotext = params[:notepad_text];
      parent = nil
      child = nil
      grandchild = nil
      rt_server = Dirt::RT::Server.new(Dirt::CONFIG[:rt_url])
      infotext.each_line do |line|
        line.gsub!(/^(\**)\s?(-)?\s?([a-zA-Z0-9\$%_\*\+\s]*)\s?-?\s?([a-zA-Z0-9\$%_\*\+\s]*)?/) do |match|
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
                  p 'parent not defined'
                else
                  rt_server.addComment(parent, comment_subject, session)
                end
              when 2
                # comment - child ticket
                if child.nil?
                  p 'child not defined'
                else
                  rt_server.addComment(child, comment_subject, session)
                end
              when 3
                # comment - grandchild ticket
                if grandchild.nil?
                  p 'grandchild not defined'
                else
                  rt_server.addComment(grandchild, comment_subject, session)
                end
            end
              
          else 
            # its a ticket
            response = rt_server.createTicket(comment_subject, text, session)
            ticketId = ""
            
            response.body.gsub!(/^#\sTicket\s([0-9]*)\screated./) do
              ticketId = $1
            end

            p '\n\n\n\n\n\n'
            p ticketId
            p '\n\n\n\n\n\n'

            case heir.length.to_s
              when "1"
                # parent ticket
                parent = ticketId
              when "2"
                # child ticket
                child = ticketId
                if parent.nil?
                  p 'parent not defined'
                else
                  response = rt_server.addParent(child, parent, session)
                end
              when "3"
                # grandchild ticket
                grandchild = ticketId
                p "grandchild fixed"
                if parent.nil?
                  p 'child not defined'
                else
                  response = rt_server.addParent(grandchild, child, session)
                end
            end

          end

        end
      end
    end

  end

end
