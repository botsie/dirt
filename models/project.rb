#!/usr/bin/env ruby

require "sequel"

module Dirt
  class Project < Sequel::Model(Dirt::DIRT_DB)
    set_primary_key :id
    one_to_many :pages
    one_to_many :statuses

    def self.persist(args = {})
      
      if args[:tab_spec].nil? or args[:tab_spec].empty?
        args[:tab_spec] = %q([{"caption":"Index", "page":"index"}])
      end

      if args[:id].empty?
        self.insert(
          :name => args[:name],
          :identifier => args[:identifier],
          :description => args[:description],
          :tab_spec => args[:tab_spec],
          :taskboard => args[:taskboard]
          )
      else
        self.where(:id => args[:id]).update(
          :name => args[:name],
          :description => args[:description],
          :tab_spec => args[:tab_spec],
          :taskboard => args[:taskboard]
          )
      end
    end
  end 
end
