#!/usr/bin/env ruby

require 'uri'
require 'net/http'

module Dirt
  module RT

    class Server
      def initialize(url)
        @base_url = url
      end

      def http(path, method, data='', cookie='')
        uri = URI(@base_url+"/REST/1.0"+path)
        req = Net::HTTP.new(uri.host, uri.port)
        req.use_ssl = true
        headers = cookie.nil? ? {}:{'Cookie' => cookie}


        if !data.nil?
          reqdata = ''
          data.each do |key,value|
            reqdata += key.to_s+"="+value.to_s+"&"
          end
        end

        if(method =='GET')
          resp = req.get( uri.path, reqdata, headers)
        elsif(method == 'POST')
          resp = req.post( uri.path, reqdata, headers) 
        end

        return resp
      end

      def authenticate(params)
        user = params[:user_id]
        pass = params[:password]

        response = http("", 'POST', {'user' => user, 'pass' => pass})

        if response.body.split('\n').first =~ /200 Ok/ then
          return response['set-cookie'].split('; ')[0]
        elsif response.body.split('\n').first =~ /401 Credentials required/ then
          raise "Your username or password is incorrect"
        elsif response.body.split('\n').first =~ /401 Credentials required/ then
          raise "Your have insufficient RT privileges"
        else
          raise "Got #{response.code} #{response.message} when trying to #{@base_url} body='#{response.body}'"
        end
      end

      def addcomment(message, ticketId, session)
        return
      end
      
    end

  end
end


