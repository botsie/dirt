#!/usr/bin/env ruby

module Dirt

  class UserController < Dirt::Controller
    def show(params, session)
      puts params
      @redirect_to = params[:redirect_to]
      @failure_message = params[:failure_message]
      haml :profile
    end

    def edit(params, session)
      haml :profile_edit
    end

  end
end