#!/usr/bin/env ruby

require 'json'

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
      status = @new ? Hash.new : Dirt::Status.where(:project_id => @project[:id]).all
      @status = Array.new;
      status.each do |val|
        @status.push({:kanban => val[:status_name], :RT => val[:rt_status_id]})
      end
      @status = @status.to_json
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

      params[:statuses].each do |status|
        if !status["kanban"].empty?
          Dirt::Status.persist(:project_id => params[:id], :status_name => status["kanban"] , :rt_status_id => status["RT"])
        end
      end

    end
  end
end