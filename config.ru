#!/usr/bin/env ruby
# Id$ nonnax 2022-03-29 12:19:10 +0800
require_relative 'app'

# 
use CacheConf, {
  %r{/} => {
     :cache_control => "max-age=86400", :expires => 86400
    }
}

# use StupidCache, :cache => MemCache.new(%w(10.0.0.1 10.0.0.2))

use Rack::Static, :urls => ["/static"]
# require 'rack/cache'
# use Rack::Cache,
  # metastore:    'file:/var/cache/rack/meta',
  # entitystore:  'file:/var/cache/rack/body',
  # verbose:      true

# use Rack::Cache,
  # metastore:   'heap:/',
  # entitystore: 'heap:/',
  # verbose: true

run Loonatic
