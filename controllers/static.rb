#!/usr/bin/env ruby

require 'redcloth'
require 'haml'

module Dirt
  class StaticController < Dirt::Controller
  	def show(params)
  		if defined? (params[:page].to_s)
  			send(params[:page].to_s, params)
  		elsif
  			notfound(params)
  		end
    end

    def notfound(params)
    	haml "static/not_found"
    end

    def help(params)
      params[:subpage] = "home" if params[:subpage].nil? || params[:subpage].empty?
      if File.exists?("views/static/help/"+params[:subpage].to_s+".textile")
        @page = RedCloth.new(File.read("views/static/help/"+params[:subpage].to_s+".textile")).to_html
        layout = File.read('views/layout.haml')
        template = File.read('views/static/help.haml')
        layout_engine = Haml::Engine.new(layout)
        layout_engine.render(self) do
          template_engine = Haml::Engine.new(template, :format => :html5)
          template_engine.render(self)
        end
      else
        notfound(params)
      end
    end

  end
end