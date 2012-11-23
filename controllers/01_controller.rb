#!/usr/bin/env ruby

# This file needs to be loaded before the other controllers, hence the name 
# 01_controller.rb

require "json"

module Dirt
  class Controller

    attr_accessor :tab_spec

    def self.show(params)
      controller = self.new
      controller.get_tab_spec(params[:project], params[:page])
      controller.show(params)
    end 

    def self.edit(params)
      controller = self.new
      controller.get_tab_spec(params[:project], params[:page])
      controller.edit(params)
    end 

    def self.save(params)
      controller = self.new
      controller.get_tab_spec(params[:project], params[:page])
      controller.save(params)
    end 

    def get_tab_spec(project_name, page_name)
      @tab_spec = JSON.parse(Dirt::Project.where(:identifier => project_name).first.tab_spec, :symbolize_names=>true)
      @tab_spec.each {|t| t[:page] == page_name ? t[:class] = "active" : t[:class] = ""}
    end

    def haml( template_id )
      layout = File.read('views/layout.haml')
      template = File.read('views/' + template_id.to_s + '.haml')
      layout_engine = Haml::Engine.new(layout)
      layout_engine.render(self) do
        template_engine = Haml::Engine.new(template)
        template_engine.render(self)
      end
    end
  end 
end