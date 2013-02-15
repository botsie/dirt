#!/usr/bin/env ruby

module Dirt
  class LoginController < Dirt::Controller
    def show(params, session)
      puts params
      @redirect_to = params[:redirect_to]
      haml :login
    end

    def self.authenticate(params, session)
    end
  end
end