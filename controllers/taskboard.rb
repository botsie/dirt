#!/usr/bin/env ruby

require 'json'
require 'haml'
require 'chronic'

module Dirt
  class TaskboardController < Dirt::Controller
    def show(params)
      # Get IDs of Parent Cards
      @project = params[:project]
      project = Dirt::Project.where(:identifier => @project).first
      @tab_spec = Dirt::PageController.new(session).get_tab_spec(@project,"../taskboard")
      if project[:taskboard] == "" || project[:taskboard].nil?
      	@error_msg = "Taskboard not defined"
      	return haml :taskboard
      end
      begin
      	@spec = JSON.load(project[:taskboard])
      rescue JSON::ParserError => error
      	@error_msg = error.message
      	return haml :taskboard
      end
      @spec[:project_id] = project[:id]
      @model = Dirt::Taskboard.new(@spec)
      @model.cards
      text = haml :taskboard

      text.gsub(/#([0-9]+)/) do |m|
        %Q{<a href="#{Dirt::CONFIG[:rt_url]}/Ticket/Display.html?id=#{$1}" target="_blank">##{$1}</a>}
      end 
    end    
  end
end
