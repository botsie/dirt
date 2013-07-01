#!/usr/bin/env ruby

module Dirt

  class ProfileController < Dirt::Controller
    def show(params)
      haml :profile
    end

    def edit(params)
      haml :profile_edit
    end

    def save(params)
      
    end
  end
end