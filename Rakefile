begin
  require 'bundler/setup'
rescue LoadError
  puts "Please install Bundler and run 'bundle install' to ensure you have all dependencies"
end

desc "Clean the site"
task :clean do
  rm_rf "_site"
end

desc "Generate the site using Jekyll"
task :generate => :check_pygments do
  ruby "-S bundle exec jekyll"
end
task :gen => :generate
task :default => :generate

desc "Run a file server that serves and regenerates the files"
task :server  do
  ruby "-S bundle exec rackup"
end

task :check_pygments do
  `pygmentize -V`
  $?.success? or raise "Pygments not installed, see http://pygments.org/docs/installation/"
end
