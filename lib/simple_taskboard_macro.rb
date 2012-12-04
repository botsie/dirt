#!/usr/bin/env ruby

require 'json'
require 'haml'
require 'chronic'

module Dirt

  class SimpleTaskBoardMacro < Macro
    def to_html
      # Get IDs of Parent Cards
      model = SimpleTaskBoardMacroModel.new(@spec)
      haml :simple_task_board, model      
    end    
  end

end
