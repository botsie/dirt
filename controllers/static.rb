#!/usr/bin/env ruby

module Dirt
  class StaticController < Dirt::Controller
  	def show(params, session)
  		if defined? (params[:page].to_s)
  			send(params[:page].to_s)
  		elsif
  			notfound
  		end
    end

    def notfound
    	haml "static/not_found"
    end

    def help
    	haml "static/help"
    end

    def about
    	haml "static/about"
    end

  end
end