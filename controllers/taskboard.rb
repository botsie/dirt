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
      	@error_msg = error.message.force_encoding("utf-8")
      	return haml :taskboard
      end
      @spec[:project_id] = project[:id]
      @model = Dirt::Taskboard.new(@spec)
      @model.cards
      haml :taskboard
    end 

    def render_card(card)
      template = File.read('views/card.haml')
      template_engine = Haml::Engine.new(template, :format => :html5)
      template_engine.render(self, :card => card)
    end
   
  end
end
