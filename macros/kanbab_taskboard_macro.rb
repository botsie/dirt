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
    
    def lanes
      #lanes = @spec['group_sequence'] 
      #lanes ||= ['new', 'open', 'stalled', 'resolved']
      #return lanes
    end

    def grp_seq
      @grp_seq = @spec['group_sequence']
      #grp_seq ||= 
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

    #def streams
    #end 

    #def stream_ids
    #end

    #def stream_members(stream_id)
    #end    

    #def cards
    #end

    #def stream_cards(args)
    #end

    #def misc_cards(args)
    #end

    def shorten(str)
      max_length = 27
      if str.length > max_length
        return str[0..max_length] << "..."
      else
        return str
      end
    end

    #def classify(time)
    #end

   
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
