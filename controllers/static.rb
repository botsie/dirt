#!/usr/bin/env ruby

module Dirt
  class StaticController < Dirt::Controller
  	def show(params)
  		if defined? (params[:page].to_s)
  			send(params[:page].to_s)
  		elsif
  			notfound
  		end
    end

    def notfound
    	haml "static/not_found"
    end

  end
end