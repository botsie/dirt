#!/usr/bin/env ruby

module Dirt

  class UserController < Dirt::Controller
    def index(params)
      if defined? self.(params[:page])
        self.params[:page];
      elsif 
        raise unless e.message == "Page Not Found"
      end
    end

    def help(params)
      haml :help
    end

    def about(params)
      haml :about
    end

  end
end