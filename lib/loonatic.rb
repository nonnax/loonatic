#!/usr/bin/env ruby
# Id$ nonnax 2022-03-29 13:11:21 +0800
# Loonatic
# small rack framework
require_relative 'http_utils'
# keys_to_sym, keys_to_str

module Loonatic
  @headers_default = {'Content-Type'=>'text/html; charset=UTF-8'}
  @status = 200
  @routes = { 'GET' => [], 'POST' => [], 'PUT' => [], 'DELETE' => [] }
  @options = {}

  def self.route(method, path_info, **opts, &block)    
    compiled_path, extra_params=compile_path_params(path_info)
    r = {path_info:, compiled_path:, extra_params:, opts: opts, block:}
    @routes[method] << r 
  end
  
  def self.headers(h) @res.headers.merge!(h.keys_to_str) end
  def self.content_type(type) self.headers({'Content-Type'=> type }) end
  def self.status(status) @res.status=status  end
  def self.set(key, value) @options[key]= value  end
  def self.req() @req end
  def self.res() @res end
  def self.env() @env end
  
  def self.eval_route(env)
    @req=Rack::Request.new(env)
    @res=Rack::Response.new
    
    route=@routes[req.request_method].detect {|r| r[:compiled_path].match(req.path_info)}
    if route
      params=route[:extra_params].zip(Regexp.last_match.captures).to_h rescue {}
      headers( route[:opts] )
      @body=instance_exec(req.params.merge(params), &route[:block] ) rescue nil # bypass favicon.ico, etc errors :-)
      res.write @body
    end
  end
  
  def self.call(env)
    self.eval_route(env)    
    return res.finish if @body
    [404, @headers_default, ['Not Found']]
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
end

module Kernel
  def get(path,  **opts, &block) ::Loonatic.route 'GET',  path, **opts, &block end
  def post(path, **opts, &block) ::Loonatic.route 'POST', path, **opts, &block end
  def put(path,  **opts, &block) ::Loonatic.route 'PUT', path, **opts, &block end
  def delete(path,  **opts, &block) ::Loonatic.route 'DELETE', path, **opts, &block end
  def headers(h)      ::Loonatic.headers(h) end
  def status(status)  ::Loonatic.status( status) end
  def set(key, value) ::Loonatic.set( key, value) end
end
