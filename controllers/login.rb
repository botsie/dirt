#!/usr/bin/env ruby

module Dirt

  class LoginController < Dirt::Controller
    def show(params, session)
      puts params
      @redirect_to = params[:redirect_to]
      @failure_message = params[:failure_message]
      haml :login
    end

    def logout
      session.delete(:user_id)
      session.delete(:rt_cookie)
      redirect_to = "/"
    end

    def self.authenticate(params, session)

      rt_server = Dirt::RT::Server.new(Dirt::CONFIG[:rt_url])
      
      cookie = rt_server.authenticate(user_id: params[:user_id], password: params[:password])

      session[:user_id] = params[:user_id]
      session[:rt_cookie] = cookie

      return 
    end
  end
end