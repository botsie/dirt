require 'bundler'
Bundler.require

ENV["RACK_ENV"] ||= "development"

require File.join(File.dirname(__FILE__), 'application.rb')

run Dirt::Application.new
