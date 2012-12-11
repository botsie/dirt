#!/usr/bin/env ruby

require "sequel"
require "redcloth"

require File.expand_path('../../lib/macro.rb', __FILE__)
Dir[File.expand_path('../../lib/*_macro.rb', __FILE__)].sort.each { |f| require f }

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

      pre_processed_src = render_extensions(project, page_name, page[:content])

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

    def self.render_extensions(project, page_name, text)
      # expand wikilinks
      text.gsub!(/\[\[(.*?)\]\]/) {|m| %Q(["#{$1}":/projects/#{project}/pages/#{$1}]) }

      text.gsub(/<~(.*?)~>/m) do |match_string|
        begin
          Dirt::Macro.to_html($1.chomp)
        rescue Exception => e
          e.message
        end
      end
    end
  end	
end
