#!/usr/bin/env ruby

module Dirt

  class StaticController < Dirt::Controller
    def show (params, session)
      if defined? (params[:page])
        send(params[:page])
      elsif 
        raise message == "Page Not Found"
      end
    end

    def help
      haml :help
    end

    def about
      haml :about
    end

  end
end