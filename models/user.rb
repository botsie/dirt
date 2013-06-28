#!/usr/bin/env ruby

require "sequel"

module Dirt
  class User < Sequel::Model(Dirt::DIRT_DB)
    set_primary_key :id

    def self.get(user_id)
      return Dirt::User.new(user_id) unless user_id.nil?
    end

    def self.persist(user_id)
      row = self.where(:uname => user_id).first
      if row.nil?
        self.insert(:uname => user_id, :editor => 1)
      end
      return self.where(:uname => user_id).first
    end

    def initialize(user_id)
      @user_id = user_id
    end


  end
end