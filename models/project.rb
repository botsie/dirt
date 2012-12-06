#!/usr/bin/env ruby

require "sequel"

module Dirt
  class Project < Sequel::Model(Dirt::DIRT_DB)
    set_primary_key :id
    one_to_many :pages

    def self.persist(args = {})
      if args[:id].empty?
        self.insert(
          :name => args[:name],
          :identifier => args[:identifier],
          :description => args[:description],
          :tab_spec => args[:tab_spec]
          )
      else
        self.where(:id => args[:id]).update(
          :name => args[:name],
          :description => args[:description],
          :tab_spec => args[:tab_spec]
          )
      end
    end
  end 
end
