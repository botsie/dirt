#!/usr/bin/env ruby

module Dirt
  class PageController < Dirt::Controller
    def show(params)
      @project = params[:project]
      @page_name = params[:page]
      @page = Dirt::Page.html(@project, @page_name)
      haml :page
    end

    def edit(params)
      @project = params[:project]
      @page_name = params[:page]
      @page = Dirt::Page.source(@project, @page_name)
      haml :page_edit
    end

    def save(params)
      # TODO: escape content to prevent SQL injection
      Dirt::Page.where(:id => params[:id]).update(:content => params[:content])
      show(params)
    end 
  end
end