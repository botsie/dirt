#!/usr/bin/env ruby

module Dirt
  class ProjectApiController < Dirt::Controller
    def show(params)
      project = params[:project]
      method = params[:method]

      return {status: "400", message: "Projects API: resource #{method} not found"} unless method =~ /(cards|statuses)/

      self.send(method.tr('-','_').to_sym, project)
    end

    def cards(project_identifier)
      Dirt::ProjectApiModel.new.cards(project_identifier)
    end

    def kanban_statuses(project_identifier)
      Dirt::Status.status(project_identifier)
    end

  end
end
