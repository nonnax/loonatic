#!/usr/bin/env ruby
# Id$ nonnax 2022-03-29 16:07:57 +0800
class CacheConf
  attr :app, :pat
  def initialize app, pat
    @app = app
    @pat = pat
  end

  def call env
    trio = app.call(env)
    path = env["REQUEST_PATH"]
    pat.each do |pattern, data|
      if path.match?(pattern)
        trio[1]["Cache-Control"] = data[:cache_control] if data.has_key?(:cache_control)
        trio[1]["Expires"] = (Time.now + data[:expires]).utc.rfc2822 if data.has_key?(:expires)
      end
    end
    trio
  end
end
