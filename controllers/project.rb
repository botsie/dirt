#!/usr/bin/env ruby

module Dirt
  class ProjectController < Dirt::Controller
    def show(params)
      @projects = Dirt::Project.all
      haml :projects
    end

    def edit(params)
      @new = params[:new]
      @disable_identifier = !@new
      @project_id = params[:project]
      @post_target = @new ? "/projects/new/save" : "/projects/#{@project_id}/save"
      @project = @new ? Hash.new : Dirt::Project.where(:identifier => @project_id).first
      haml :project_edit
    end

    def save(params)
      Dirt::Project.persist(
        :id => params[:id],
        :name => params[:name],
        :identifier => params[:identifier],
        :description => params[:description],
        :tab_spec => params[:tab_spec]
        )
    end
  end
end