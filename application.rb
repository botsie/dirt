#!/usr/bin/env ruby

require 'mysql2'
require 'sequel'
require 'sinatra'
require 'haml'
require 'pp'
require 'logger'
require 'yaml'
require 'uri'

use Rack::Logger 

module Dirt


  class Application < Sinatra::Application
    CONFIG_FILE = File.join(File.dirname(__FILE__), 'config/config.yml')
    DB_CONFIG_FILE = File.join(File.dirname(__FILE__), 'config/database.yml')

    def array_match(value, array)
      found = false
      array.each do |v|
        found = (value =~ v)
        break if found
      end
      return found
    end 

    def self.load_config(file_name)
      env = ENV["RACK_ENV"]
      data = YAML::load(File.open(file_name))[env]

      raise "No configration found in #{file_name} for RACK_ENV environment '#{env}'. Check #{file_name} for valid values of RACK_ENV" if data.nil?

      data.inject({}) { |memo, (k,v)| memo[k.to_sym] = v; memo }
    end

    configure do
      set :logging, true
      # enable :sessions

      Dirt::CONFIG = load_config(CONFIG_FILE)
      db_config = load_config(DB_CONFIG_FILE)

      Dirt::RT_DB = Sequel.connect(db_config[:rt])
      Dirt::RT_DB.loggers << Logger.new($stdout)

      Dirt::DIRT_DB = Sequel.connect(db_config[:dirt])
      Dirt::DIRT_DB.loggers << Logger.new($stdout)

      use Rack::Session::Cookie, :key => 'rack.session',
                                 :path => '/',
                                 :secret => 'qwedsa123'

      if Dirt::CONFIG[:log_sql]
        sql_log_file = Dirt::CONFIG[:sql_log_file]
        sql_logger = Logger.new(sql_log_file)

        Dirt::RT_DB.loggers << sql_logger
        Dirt::DIRT_DB.loggers << sql_logger
      end

      Dir['lib/*.rb'].sort.each { |lib| require File.join(File.dirname(__FILE__), lib) }
      Dir['models/*.rb'].sort.each { |model| require File.join(File.dirname(__FILE__), model) }
      Dir['controllers/*.rb'].sort.each { |controller| require File.join(File.dirname(__FILE__), controller) }
    end

    before do 
      @user = Dirt::User.get(session[:user_id])
      path = request.path_info

      if @user.nil? and not array_match(path, [/login/,/favicon/])
        redirect to("/login?redirect_to=#{path}")
      end        
    end
    # -----------------------------------------------------------------
    # App Related Routes
    # -----------------------------------------------------------------

    get '/login' do
      Dirt::LoginController.show(params) 
    end

    post '/login' do
      begin
        Dirt::LoginController.authenticate(params, session)
      rescue => error
        redirect to("/login?redirect_to=#{params[:redirect_to]}&failure_message=#{error.message}")
      end
      redirect to(params[:redirect_to])
    end

    get '/logout' do
      @success_message = Dirt::LoginController.logout(params, session)
      haml :login
    end

   # get '/:queue' do
   #   Dirt::CardWallController.show(params)
   # end
    
    # -----------------------------------------------------------------
    # Project Related Routes
    # -----------------------------------------------------------------

    get %r{(^/$|^/projects[/]*$)} do
      Dirt::ProjectController.show(params, session) 
    end

    get '/projects/new' do
      params[:new] = true
      Dirt::ProjectController.edit(params, session)       
    end

    get '/projects/:project/edit' do
      params[:new] = false
      Dirt::ProjectController.edit(params, session)
    end

    post '/projects/add' do
      Dirt::ProjectController.save(params, session)
      redirect "/projects/"
    end

    post '/projects/:project/save' do
      Dirt::ProjectController.save(params, session)
      redirect "/projects/"
    end

    # -----------------------------------------------------------------
    # Project Page related routes
    # -----------------------------------------------------------------

    get '/projects/:project' do 
      redirect "/projects/#{params[:project]}/pages/index"
    end

    get '/projects/:project/pages' do 
      redirect "/projects/#{params[:project]}/pages/index"
    end

    get '/projects/:project/pages/:page' do
      Dirt::PageController.show(params, session)
    end    

    get '/projects/:project/pages/:page/edit' do
      Dirt::PageController.edit(params, session)
    end    

    post '/projects/:project/pages/:page/save' do
      Dirt::PageController.save(params, session)
      redirect "/projects/#{params[:project]}/pages/#{params[:page]}"
    end    

    # run! if app_file == $0

    # -----------------------------------------------------------------
    # Page to handle errors
    # -----------------------------------------------------------------

    not_found do
      Dirt::StaticController.show({:page => "notfound"}, session)
    end
  end
end

