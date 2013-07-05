#!/usr/bin/env ruby

require "json"

module Dirt
  class PageController < Dirt::Controller
    def show(params)
      @project = params[:project]
      @page_name = params[:page]
      @tab_spec = get_tab_spec(@project, @page_name)

      begin
        @page = Dirt::Page.html(@project, @page_name)
      rescue RuntimeError => e
        raise unless e.message == "Page Not Found"
        edit(params)
      else
        haml :page
      end
    end

    def edit(params)
      @project = params[:project]
      @page_name = params[:page]
      @tab_spec = get_tab_spec(@project, @page_name)

      begin
        @page = Dirt::Page.source(@project, @page_name)
      rescue RuntimeError => e
        raise unless e.message == "Page Not Found"
        @page = {:content => ""}
      end
      haml :page_edit
    end

    def save(params)
      # TODO: escape content to prevent SQL injection

      Dirt::Page.persist(
        :id => params[:id],
        :page_name => params[:page_name],
        :project_id => params[:project_id],
        :content => params[:content],
        :project => params[:project]
      )

    end 

    def get_tab_spec(project_name, page_name)
      begin
        tab_spec = JSON.parse(Dirt::Project.where(:identifier => project_name).first[:tab_spec], :symbolize_names=>true)
      rescue JSON::ParserError
        tab_spec = [{:caption => "Index", :page => "index"}]
        @error_message = "Invalid Tab Specification, Using Default"
      end

      tab_spec.insert(1,{:caption=>"Notepad",:page=>"../notepad"})
      tab_spec.each {|t| t[:page] == page_name ? t[:class] = "active" : t[:class] = ""}
      return tab_spec
    end
  end
end