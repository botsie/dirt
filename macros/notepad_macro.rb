#!/usr/bin/env ruby

require 'json'
require 'haml'
require 'chronic'

module Dirt

  class NotepadMacroModel
    def initialize(spec)
      @spec = spec
    end
  end

  class NotepadMacro < Macro
    def to_html(project_name)
      # Get IDs of Parent Cards
      model = Dirt::NotepadMacroModel.new(@spec)
      content = haml :notepad, model     
      return content
    end    
  end

end
