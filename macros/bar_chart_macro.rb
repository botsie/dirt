#!/usr/bin/env ruby

require 'json'
require 'haml'
require 'chronic'

module Dirt

  class BarChartMacroModel
    def initialize(spec)
      @spec = spec
    end

    def caption
      caption = @spec['caption'] 
      caption ||= "Bar Chart"
      return caption
    end

    def info
      return @info unless @info.nil?      
      sql = @spec['sql'];
      # SOME DB OPERATION
      return @info
    end

  end

  class BarChartMacro < Macro
    def to_html
      # Get IDs of Parent Cards
      model = Dirt::BarChartMacroModel.new(@spec)
      content = haml :bar_chart, model     
      return content
    end    
  end

end
