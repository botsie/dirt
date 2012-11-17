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

    end 
  end
end