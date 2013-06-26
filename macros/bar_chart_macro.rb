#!/usr/bin/env ruby

require 'json'
require 'haml'
require 'chronic'

module Dirt

  class BarChartMacroModel
    def initialize(spec)
      @spec = spec
    end

    def type
      return "bar" if @spec['direction'] == "horizontal"
      return "column"
    end

    def caption
      caption = @spec['caption'] 
      caption ||= "Bar Chart"
      return caption
    end

    def sourcetext
      sourcetext = @spec['source']
      return sourcetext unless sourcetext.nil?
      return ""
    end

    def yaxistext
      yaxistext = @spec['y-text']
      return yaxistext unless yaxistext.nil?
      return "y axis"
    end

    def groupname
      groupname = @spec['group-sequence']
      return groupname unless groupname.nil?
      return false
    end

    def info
      return @info unless @info.nil?

      sql = @spec['sql']
      rows = Dirt::RT_DB[sql].all

      # TODO: Handle the no results case
      rows = [{"result" => "No rows to display"}] if rows.count == 0

      @info = Array.new()
      i = 0
      rows.each do |row|
        j = 0
        row.each do |key,value|
          if i==0 
            @info[j] = Array.new()
          end
          @info[j] << value
          j += 1
        end
        i += 1
      end
      return @info  
    end
  end

  class BarChartMacro < Macro
    def to_html(project_name)
      # Get IDs of Parent Cards
      model = Dirt::BarChartMacroModel.new(@spec)
      content = haml :bar_chart, model     
      return content
    end    
  end

end
