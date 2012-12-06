#!/usr/bin/env ruby

# This file needs to be loaded before the other controllers, hence the name 
# 01_controller.rb

require "json"

module Dirt
  class Controller

    attr_accessor :tab_spec

    def self.show(params)
      controller = self.new
      controller.show(params)
    end 

    def self.edit(params)
      controller = self.new
      controller.edit(params)
    end 

    def self.save(params)
      controller = self.new
      controller.save(params)
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