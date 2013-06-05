#!/usr/bin/env ruby

require "sequel"

module Dirt
  class Status < Sequel::Model(Dirt::DIRT_DB)
    set_primary_key :id
    many_to_one :projects
    one_to_many :ticket_status

    def self.persist(args = {})
      if args[:id].empty?
        project_id = Dirt::Project.where(:identifier => args[:project]).first.id
        self.insert(:status_name => args[:status_name], :project_id => project_id)
      else
        self.where(:id => args[:id]).update(:status_name => args[:status_name])
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
