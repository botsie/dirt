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

      oldstatuses = Dirt::Status.where(:project_id => params[:id]).all

      deleted_status = Array.new

      #delete all oldstatuses that are not in the new list
      if !oldstatuses.nil?
        oldstatuses.each do |oldstatus|
          flag = 0 
          if !params[:statuses].nil?
            params[:statuses].each do |newstatus|
              if oldstatus[:status_name].to_s == newstatus["kanban"].to_s
                flag = 1
                break
              end
            end
          end
          if(flag==0)
            Dirt::Status.where(:id => oldstatus[:id]).delete
            #move all tickets with the above status id to uncategorized
            Dirt::StatusTicket.where(:status_id => oldstatus[:id]).update(:status_id => '0')
          end
        end
      end
      
      if !params[:statuses].nil?
        params[:statuses].each do |newstatus|
          #update all old statuses with new rt_map id
          #if updated - do not insert
          flag = 0
          if !oldstatuses.nil?
            oldstatuses.each do |oldstatus|
              if oldstatus[:status_name] == newstatus["kanban"] && oldstatus[:rt_status_id].to_i != newstatus["RT"].to_i
                Dirt::Status.where(:id => oldstatus[:id]).update(:rt_status_id => newstatus["RT"])
                flag = 1
              end
            end
            if !newstatus["kanban"].empty? && flag==0
              Dirt::Status.persist(:project_id => params[:id], :status_name => newstatus["kanban"] , :rt_status_id => newstatus["RT"])
            end
          end
        end
      end

    end
  end
end