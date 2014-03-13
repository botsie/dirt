#!/usr/bin/env ruby

require "sequel"

module Dirt
  class Status < Sequel::Model(Dirt::DIRT_DB)
    set_primary_key :id
    many_to_one :projects
    one_to_many :status_tickets

    def self.persist(args = {})
      if args[:id].nil? || args[:id].empty? 
        project_id = "";
        if(args[:project_id].nil?)
          project_id = Dirt::Project.where(:identifier => args[:project]).first.id
        else
          project_id = args[:project_id]
        end
        result = self.where(:status_name => args[:status_name], :project_id => project_id).first
        if(result.nil?)
          self.insert(:status_name => args[:status_name], :project_id => project_id, :rt_status_id => args[:rt_status_id], :max_tickets => args[:max_tickets])
        else
          result.update(:status_name => args[:status_name], :rt_status_id => args[:rt_status_id], :max_tickets => args[:max_tickets])
        end
      else
        self.where(:id => args[:id]).update(:status_name => args[:status_name], :rt_status_id => args[:rt_status_id], :max_tickets => args[:max_tickets].nil? ? 0 : args[:max_tickets])
      end
    end

    def self.source(project)
      begin
        statuses = self.ungraphed().where(:project__identifier => project)
      rescue 
        return {}
      end
      return statuses
    end

    def self.status(project)
      sql = "SELECT statuses.* FROM statuses, projects 
             WHERE statuses.project_id = projects.id
             AND projects.identifier = ?
             and status_name <> ''"

      return Dirt::DIRT_DB[sql, project].all
    end

  end 
end
