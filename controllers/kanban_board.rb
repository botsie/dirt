#!/usr/bin/env ruby

require 'json'
require 'haml'
require 'chronic'

module Dirt
  class KanbanBoardController < Dirt::Controller

    def show(params)

      @project = params[:project]
      project = Dirt::Project.where(:identifier => @project).first
      @tab_spec = Dirt::PageController.new(session).get_tab_spec(@project,"../taskboard")

      if project[:taskboard] == "" || project[:taskboard].nil?
      	@error_msg = "Kanban Board not defined"
      	return haml :taskboard
      end

      begin
      	@spec = JSON.load(project[:taskboard])
      rescue JSON::ParserError => error
      	@error_msg = error.message
      	return haml :kanban_board
      end
      @spec[:project_id] = project[:id]

      haml :kanban_board
    end    
  end
end
