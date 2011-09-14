# -*- ruby -*-
#
# This rackup file runs the equivalent of jekyll --server --auto, but
# uses Rack to add a couple of rewrite rules to make it equivalent to the
# Apache configuration.

### This section copied from bin/jekyll file
require 'jekyll'

options = Jekyll.configuration({})
source      = options['source']
destination = options['destination']

# Files to watch
def globs(source)
  Dir.chdir(source) do
    dirs = Dir['*'].select { |x| File.directory?(x) }
    dirs -= ['_site']
    dirs = dirs.map { |x| "#{x}/**/*" }
    dirs += ['*']
  end
end

# Create the Site
site = Jekyll::Site.new(options)

# Watch for updates
require 'directory_watcher'

puts "Auto-regenerating enabled: #{source} -> #{destination}"

dw = DirectoryWatcher.new(source)
dw.interval = 1
dw.glob = globs(source)

dw.add_observer do |*args|
  t = Time.now.strftime("%Y-%m-%d %H:%M:%S")
  puts "[#{t}] regeneration: #{args.size} files changed"
  site.process
end

dw.start

### Rackup server stuff starts here

# Emulate the following Apache config:
# * / => /index.html
# * RewriteRule ([^.]+)$ $1.html
# * ErrorDocument 404 /404.html
class DotHtmlRewriter
  def initialize(app, fourohfour)
    @app = app
    @fourohfour = fourohfour
  end

  def call(env)
    env["PATH_INFO"] += "index.html" if env["PATH_INFO"] =~ /\/$/
    result = @app.call(env)
    if result[0] == 404 && env["PATH_INFO"] !~ /\.html$/
      env["PATH_INFO"] += ".html"
      second_result = @app.call(env)
      if second_result[0] != 404
        result = second_result
      else
        result[2] = [File.read(@fourohfour)]
        result[1]["Content-Type"] = "text/html"
        result[1]["Content-Length"] = result[2][0].length.to_s
      end
    end
    result
  end
end

puts "Server running on http://localhost:9292"
use DotHtmlRewriter, "#{destination}/404.html"
run Rack::File.new(destination)
