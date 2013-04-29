#!/usr/bin/env ruby


require 'net/http'

user = 'biju.ch'
pass = '1qaz@ws'
#uri = URI('https://sysrt.ops.directi.com/REST/1.0/ticket/123/show')
uri = URI('https://sysrt.ops.directi.com/REST/1.0')

req = Net::HTTP::Post.new(uri.path)
req.set_form_data('user' => user, 'pass' => pass)

res = Net::HTTP.start(uri.hostname, uri.port, 
  :use_ssl => uri.scheme == 'https', 
  :set_debug_output => $stderr) do |http|
  http.request(req)
end

case res
when Net::HTTPSuccess, Net::HTTPRedirection
  # OK
  puts "HTTP response code:  #{res.code}"
  puts "HTTP message: #{res.message}"
  puts "Response:"

  res.each do |key,val|
    puts "#{key} => #{val}"
  end

  puts "Data:"
  puts res.body
else
  res.value
end


