#!/usr/bin/env ruby

module Dirt
  class ProjectController < Dirt::Controller
    def show(params)
      @projects = Dirt::Project.all
      haml :projects
    end

    def edit(params)
    end

    def save(params)
    end
  end
end