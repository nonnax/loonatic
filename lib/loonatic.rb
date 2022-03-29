#!/usr/bin/env ruby
# Id$ nonnax 2022-03-29 13:11:21 +0800
# Loonatic
# small rack-aware framework
module Loonatic
  @headers_default = {'Content-type'=>'text/html; charset=UTF-8'}
  @status = 200
  @routes = { 'GET' => [], 'POST' => [] }
  @options = {}

  def self.route(method, path_info, &block)    
    compiled_path, extra_params=compile_path_params(path_info)
    p r = {path_info:, compiled_path:, extra_params:, block:}
    
    @routes[method] << r 
  end
  def self.headers(h) @res.headers.merge!(h) end
  def self.content_type(type) self.headers({'Content-type'=> type }) end
  def self.status(status) @res.status=status  end
  def self.set(key, value) @options[key]= value  end
  def self.req() @req end
  def self.res() @res end
  
  def self.eval_route(env)
    @req=Rack::Request.new(env)
    @res=Rack::Response.new
    
    route=@routes[req.request_method].detect {|r| r[:compiled_path].match(req.path_info)}
    params=route[:extra_params].zip(Regexp.last_match.captures).to_h rescue {}
    
    @body=instance_exec(req.params.merge(params), &route[:block] ) rescue nil # bypass favicon.ico, etc errors :-)
    res.write @body
  end
  
  def self.call(env)
    self.eval_route(env)    
    return res.finish if @body
    [404, @headers_default, ['Not Found']]
  end

  def self._extra_params_of(path)
    _path, extra_params=path
    _path.match(req.path_info)
    extra_params.zip(Regexp.last_match.captures).to_h rescue {}
  end

  def self.compile_path_params(path)
    extra_params = []
    compiled_path = path.gsub(/:\w+/) do |match|
      extra_params << match.gsub(':', '').to_sym
      '([^/?#]+)'
    end
    [/^#{compiled_path}$/, extra_params]
  end

end

module Kernel
  def get(path, **opts, &block)  ::Loonatic.route 'GET', path, &block  end
  def post(path, **opts, &block) ::Loonatic.route 'POST', path, &block end
  def headers(h)      ::Loonatic.headers(h) end
  def status(status)  ::Loonatic.status( status) end
  def set(key, value) ::Loonatic.set( key, value) end
end
