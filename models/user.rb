#!/usr/bin/env ruby

require "sequel"

module Dirt
  # class User < Sequel::Model(Dirt::DIRT_DB)
  class User
    # set_primary_key :id

    def self.get(user_id)
      return Dirt::User.new(user_id) unless user_id.nil?
    end

    def initialize(user_id)
      @user_id = user_id
    end
  end
end