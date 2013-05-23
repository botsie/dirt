#!/usr/bin/env ruby

require 'json'
require 'haml'
require 'chronic'

module Dirt

  class PieChartMacroModel
    def initialize(spec)
      @spec = spec
    end

    def caption
      caption = @spec['caption'] 
      caption ||= "Pie Chart"
      return caption
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
        @info[i] = Array.new()
        row.each do |key, value|
          @info[i] << value
        end
        i += 1
      end

      return @info  
    end
  end

  class PieChartMacro < Macro
    def to_html
      # Get IDs of Parent Cards
      model = Dirt::PieChartMacroModel.new(@spec)
      content = haml :pie_chart, model     
      return content
    end    
  end

end
