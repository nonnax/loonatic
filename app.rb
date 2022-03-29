#!/usr/bin/env ruby
# Id$ nonnax 2022-03-29 12:19:05 +0800
require_relative 'lib/loonatic'
require 'json'

get '/' do |params|
  content_type 'application/json'
  {data: [params, req]}.to_json
end

get '/:id' do |params|
  {data: [params, req]}.inspect
end

get '/red' do |params|
  p 'redirecting...'
  res.redirect '/'
end
