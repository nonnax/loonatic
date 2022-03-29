#!/usr/bin/env ruby
# Id$ nonnax 2022-03-29 19:36:11 +0800
require 'uri'

module QueryStringHelper
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

  def _repeat_keys
    URI.encode_www_form(self)
  end
  private :_repeat_keys
  
  def keys_to_str
    transform_keys{|k| k.to_s.split('_').map(&:capitalize).join('-')}
  end

  def keys_to_sym
    transform_keys{|k| k.to_s.tr('-', '_').downcase.to_sym}
  end
end

Hash.include(QueryStringHelper)
