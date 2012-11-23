#!/usr/bin/env ruby

require "sequel"
require "redcloth"

require File.expand_path('../../lib/macro.rb', __FILE__)

module Dirt
  class Page < Sequel::Model(Dirt::DIRT_DB)
    set_primary_key :id
    many_to_one :project

    def self.source(project, page_name)
    	page = self.eager_graph(:project).where(:pages__name => page_name, :project__identifier => project).first
      raise "Page Not Found" if page.nil?
    	page
    end	

    def self.html(project, page_name)
    	page = self.source(project, page_name)

      pre_processed_src = expand_macros(page[:content])

	    page[:html] = RedCloth.new(pre_processed_src).to_html
	    page
    end

    def self.persist(args = {})
      if args[:id].empty?
        project_id = Dirt::Project.where(:identifier => args[:project]).first.id
        self.insert(:name => args[:page_name], :project_id => project_id, :content => args[:content])
      else
        self.where(:id => args[:id]).update(:content => args[:content])
      end
    end

    def self.expand_macros(text)
      text.gsub(/<~(.*?)~>/m) do |match_string|
        Dirt::Macro.to_html($1.chomp)
      end
    end
  end	
end