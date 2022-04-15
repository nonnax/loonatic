#!/usr/bin/env ruby
# Id$ nonnax 2022-03-29 13:11:21 +0800
# Loonatic
# small rack framework
require_relative 'http_utils'
require 'json'

module Loonatic
  class Response < Rack::Response
    def json(**h)
      self.headers[Rack::CONTENT_TYPE]='application/json'
      h.to_json
      self.write h.to_json
    end
    def html(s)
      self.headers[Rack::CONTENT_TYPE]='text/html; charset=utf-8'
      self.write s
    end
  end
  @routes = { 'GET' => [], 'POST' => [], 'PUT' => [], 'DELETE' => [] }
  @options = {} # server opts

  class << self
    attr :routes
  end

  def self.route(method, path_info, **opts, &block)    
    compiled_path, extra_params=compile_path_params(path_info)
    r = {path_info:, compiled_path:, extra_params:, opts: opts, block:}
    @routes[method] << r 
  end

  def self.set(key, value) @options[key]= value  end

  
  def self.new
    Rack::Builder.new do 
      use Rack::Static, urls: %w[/css /js /img /media], root: 'public'
      run App.new
    end
  end
  
  private  
  def self.compile_path_params(path)
    extra_params = []
    compiled_path = path.gsub(/:\w+/) do |match|
      extra_params << match.gsub(':', '').to_sym
      '([^/?#]+)'
    end
    [/^#{compiled_path}\/?$/, extra_params]
  end
  
  class App
    DEFAULT_HEADER = {'Content-Type'=>'text/html; charset=UTF-8'}
    @status = 200
    attr :req, :res, :env
    
    def status(status) res.status=status  end
    def headers(h) res.headers.merge!(H(h).keys_to_str) end
    def content_type(type) headers({Rack::CONTENT_TYPE =>type}) end

    def eval_route(env)
      @req=Rack::Request.new(env)
      @res=Loonatic::Response.new
      @env=env
      
      route=::Loonatic.routes[req.request_method].detect {|r| r[:compiled_path].match(U.clean_path_info(req.path_info))}
      if route
        params=route[:extra_params].zip(Regexp.last_match.captures).to_h rescue {}
        headers( route[:opts] )
        body=instance_exec(req.params.merge(params), &route[:block] ) rescue nil # bypass favicon.ico, etc errors :-)
        # res.write body
      end
    end
    
    def call(env)
      eval_route(env)    
      return res.finish unless res.body.empty?
      [404, DEFAULT_HEADER, ['Not Found']]
    end
    
  end
end

module Kernel
  %w(GET POST PUT DELETE).map do |m|
    define_method(m.downcase){ |path,  **opts, &block| ::Loonatic.route m,  path, **opts, &block }
  end
  
  def headers(h)      ::Loonatic.headers(h) end
  def status(status)  ::Loonatic.status( status) end
  def set(key, value) ::Loonatic.set( key, value) end
end
