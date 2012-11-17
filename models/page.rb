#!/usr/bin/env ruby

require "sequel"
require "redcloth"

module Haml::Filters::Markdown
  include Haml::Filters::Base

  def render(text)
  end
end



module Dirt
  class Page < Sequel::Model(Dirt::DIRT_DB)
    set_primary_key :id
    many_to_one :project

    def self.source(project, page_name)
    	page = self.eager_graph(:project).where(:pages__name => page_name, :project__identifier => project).first
    	page
    end	

    def self.html(project, page_name)
    	page = self.source(project, page_name)
	    page[:html] = RedCloth.new(page[:content]).to_html
	    page
    end
  end	
end
