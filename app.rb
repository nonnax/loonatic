#!/usr/bin/env ruby
# Id$ nonnax 2022-03-29 12:19:05 +0800
require_relative 'lib/loonatic'
# require_relative 'lib/cache_conf'
    
# get '/', 'Content-type'=>'application/json' do |params|
get '/' do |params|
  # content_type 'application/json'
  res.json data: [params, req, env.inspect]
end

get '/red' do |params|
  p 'redirecting...'
  res.redirect '/'
end

get '/:id' do |params|
  $updated_at ||= Time.now
  # last_modified $updated_at ||= Time.now  
  methods=self.methods.grep /last/
  res.write( {data: [params, methods]}.inspect)
end

put '/:id' do |params|
  $updated_at = nil
  res.redirect '/'
end

pp Loonatic.routes
