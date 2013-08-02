#!/usr/bin/env ruby

require 'uri'
require 'net/http'
require 'rack'

module Dirt
  module RT

    class Server
      def initialize(url)
        @base_url = url
      end

      def http(path, method, data='', cookie='')
        uri = URI(@base_url+"/REST/1.0"+path)
        req = Net::HTTP.new(uri.host, uri.port)
        req.use_ssl = (uri.scheme == "https") ? true : false
        headers = cookie.nil? ? {}:{'Cookie' => cookie}

        reqdata = Rack::Utils.build_nested_query(data)

        if(method =='GET')
          resp = req.get( uri.path, reqdata, headers)
        elsif(method == 'POST')
          resp = req.request_post( uri.path, reqdata, headers) 
        end

        return resp
      end

      def authenticate(params)
        user = params[:user_id]
        pass = params[:password]

        response = http("", 'POST', {:user => user, :pass => pass})

        if response.body.split('\n').first =~ /200 Ok/ then
          return response['set-cookie'].split('; ')[0]
        elsif response.body.split('\n').first =~ /401 Credentials required/ then
          raise "Your username or password is incorrect"
        elsif response.body.split('\n').first =~ /302/ then
          raise "Your have insufficient RT privileges"
        else
          raise "Got #{response.code} #{response.message} when trying to #{@base_url} body='#{response.body}'"
        end
      end

      def addComment(ticketId, message , session)
        message = message.gsub("\n", "\n ")
        content = "id: "+ticketId +"\n"+
                  "Action: comment\n" +
                  "Text: "+message
        return http("/ticket/#{ticketId}/comment", "POST", {:content => content}, session[:rt_cookie])
      end
      
      def createTicket(subject, session, queue, owner=nil)
        time = Time.new.to_s
        current_time = time[0 , time.length-6]

        owner = owner.nil? ? "" : owner
        queue = queue=="" ? "General" : queue

        # Please don't change this format
        # No other format works except for this one
        content = "id: ticket/new\n"+
                  "Queue: "+queue+"\n"+
                  "Requestor: " + session[:user_id]+"\n" +
                  "Subject: "+subject +"\n"+
                  "Cc: \n" +
                  "AdminCc: \n" +
                  "Owner: "+owner+"\n" +
                  "Status: new\n" +
                  "Priority: 0\n" +
                  "InitialPriority: 0\n" +
                  "FinalPriority: 0\n"+
                  "TimeEstimated: 0\n"+
                  "Starts: "+current_time+"\n"+
                  "Due: "+current_time+"\n"+
                  "Text: \n"
        return http("/ticket/new", "POST", {:content => content}, session[:rt_cookie])
      end

      def addParent(ticketId, parentId, session)
        content = "MemberOf: "+ parentId +"\n"
        return http("/ticket/#{ticketId}/links", "POST", {:content => content}, session[:rt_cookie])
      end

    end

  end
end


