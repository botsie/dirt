#!/usr/bin/env ruby

require "sequel"

module Dirt
  class Status < Sequel::Model(Dirt::DIRT_DB)
    set_primary_key :id
    many_to_one :projects
    one_to_many :status_tickets

    def self.persist(args = {})
      if args[:id].empty?
        project_id = Dirt::Project.where(:identifier => args[:project]).first.id if args[:project_id].nil?
        status = self.where(:status_name => args[:status_name], :project_id => args[:project_id]).first

        if status.nil?
          self.insert(:status_name => args[:status_name], :project_id => args[:project_id], :rt_status_id => args[:rt_status_id].nil? ? 2 : args[:rt_status_id], :max_tickets => args[:max_tickets].nil? ? 0 : args[:max_tickets])
        else
          status.update(:rt_status_id => args[:rt_status_id].nil? ? 2 : args[:rt_status_id], :max_tickets => args[:max_tickets].nil? ? 0 : args[:max_tickets])
        end
      else
        self.where(:id => args[:id]).update(:status_name => args[:status_name], :rt_status_id => args[:rt_status_id].nil? ? 2 : args[:rt_status_id], :max_tickets => args[:max_tickets].nil? ? 0 : args[:max_tickets])
      end
    end

    def self.source(project)
      statuses = self.eager_graph().where()
      return statuses
    end

    def self.status(project)
      return self.source(project)
    end

  end 
end
