#!/usr/bin/env ruby

module Dirt

  class UserController < Dirt::Controller
    def help(params)
      haml :help
    end

    def about(params)
      haml :about
    end
    
  end
end