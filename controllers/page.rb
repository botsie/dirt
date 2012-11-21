#!/usr/bin/env ruby

module Dirt
  class PageController < Dirt::Controller
    def show(params)
      @project = params[:project]
      @page_name = params[:page]
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

      show(params)
    end 
  end
end