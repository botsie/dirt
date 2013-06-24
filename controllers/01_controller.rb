#!/usr/bin/env ruby

# This file needs to be loaded before the other controllers, hence the name 
# 01_controller.rb

require "json"

module Dirt
  class Controller

    attr_accessor :tab_spec , :session

    def initialize (session=nil)
      @session = session
    end

    def self.show(params, session=nil)
      controller = self.new (session)
      controller.show(params)
    end 

    def self.edit(params, session=nil)
      controller = self.new (session)
      controller.edit(params)
    end 

    def self.save(params, session=nil)
      controller = self.new (session)
      controller.save(params)
    end 

    def haml( template_id )
      layout = File.read('views/layout.haml')
      template = File.read('views/' + template_id.to_s + '.haml')
      layout_engine = Haml::Engine.new(layout)
      layout_engine.render(self) do
        template_engine = Haml::Engine.new(template, :format => :html5)
        template_engine.render(self)
      end
    end
  end 
end