#!/usr/bin/env ruby

require 'uri'
require 'net/http'

module Dirt
  module RT

    class Server
      def initialize(url)
        @base_url = url
      end

      def authenticate(params)
        user = params[:user_id]
        pass = params[:password]
        uri = URI(@base_url + '/REST/1.0')

        request = Net::HTTP::Post.new(uri.path)
        request.set_form_data('user' => user, 'pass' => pass)

        response = Net::HTTP.start(uri.hostname, uri.port, 
                  :use_ssl => uri.scheme == 'https') do |http|
          http.request(request)
        end

        raise "Got #{response.code} #{response.message} when trying to #{@base_url}" unless response.is_a? Net::HTTPSuccess 

        if response.body.split('\n').first =~ /200 Ok/ then
          return response['set-cookie'].split('; ')[0]
        elsif response.body.split('\n').first =~ /401 Credentials required/ then
          raise "Your username or password is incorrect"
        else
          raise response.body
        end
      end
    end

  end
end


