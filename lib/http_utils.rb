#!/usr/bin/env ruby
# Id$ nonnax 2022-03-29 19:36:11 +0800
require 'uri'
require 'rack'

# decorator utils
class H<Hash
  def to_query_string(repeat_keys: false)
    repeat_keys ? send(:_repeat_keys) : send(:_single_keys)
  end

  def _single_keys
    inject([]) do |a, (k, v)|
      case v
      when Hash
        v = v._single_keys
      when Array
        v = v.join(',')
      end
      a << [k, v].join('=')
    end.join('&')
  end
  private :_single_keys

  def _repeat_keys() URI.encode_www_form(self) end
  private :_repeat_keys
  
end

class H
  # auto-symbolized hash
  def self.[](**h) H.new(**h).keys_to_sym! end  
  def initialize(**h) merge!(**h).keys_to_sym! end
  def keys_to_str()  transform_keys{|k| k.to_s.split('_').map(&:capitalize).join('-')} end
  def keys_to_sym!() transform_keys!{|k| k.to_s.tr('-', '_').downcase.to_sym} end
end

# Any decorator util
# validity of methods depend on the `base` object passed to the `()` constructor
#
class U
  attr_accessor :base
  
  def initialize(base) @base=base end  
  # string decorators
  def clean_path_info() Rack::Utils.clean_path_info(base) end 
  
  def compile_path_params
    extra_params = []
    compiled_path = base.gsub(/:\w+/) do |match|
      extra_params << match.gsub(':', '').to_sym
      '([^/?#]+)'
    end
    [/^#{compiled_path}\/?$/, extra_params]
  end
  
   # array decorators 
  def zip_captures() base.zip(Regexp.last_match.captures).to_h rescue {} end  

  # hash decorators  
  def keys_to_str() base.transform_keys{|k| k.to_s.split('_').map(&:capitalize).join('-')} end
  def keys_to_sym!() base.transform_keys!{|k| k.to_s.tr('-', '_').downcase.to_sym} end
  alias symbolize_keys keys_to_sym!  
  def to_query_string(...) H[**base].to_query_string(...) end
  
  # Rack::Utils
  def self.method_missing(m, *a, **params, &b) Rack::Utils.send(m, *a, **params, &b) end
end

module Kernel
  def H(**h) H.new(**h) end
  def U(any) U.new(any) end
  def Q(s)   Q.new(s)   end
end
