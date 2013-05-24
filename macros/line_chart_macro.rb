#!/usr/bin/env ruby

require 'json'
require 'haml'
require 'chronic'

module Dirt

  class LineChartMacroModel
    def initialize(spec)
      @spec = spec
    end

    def caption
      caption = @spec['caption'] 
      caption ||= "Line Chart"
      return caption
    end

    def yaxistext
      yaxistext = @spec['y-text']
      return yaxistext unless yaxistext.nil?
      return "y axis"
    end

    def graphlabels
      graphlabels = @spec['group-sequence']
      raise "Need a 'group-sequence' parameter to render this macro" if graphlabels.nil?
      return graphlabels
    end

    def info
      return @info unless @info.nil?

      sql = @spec['sql']
      rows = Dirt::RT_DB[sql].all

      # TODO: Handle the no results case
      raise "No rows found" if rows.count == 0

      @info = Array.new()
      i = 0
      rows.each do |row|
        j=-1
        temp = ""
        row.each do |key,value|
          j += 1
          if j==0
            temp = value
            next
          end
          if i==0 && j!=0
            @info[j-1] = Array.new() 
          end
          
          @info[j-1] << [value, temp]
        end
        i += 1
      end
      return @info  
    end
  end

  class LineChartMacro < Macro
    def to_html
      # Get IDs of Parent Cards
      model = Dirt::LineChartMacroModel.new(@spec)
      content = haml :line_chart, model     
      return content
    end    
  end

end
