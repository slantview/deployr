$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "deployr/version"
 
task :build do
  system "gem build deployr.gemspec"
end
 
task :release => :build do
  system "gem push deployr-#{Bunder::VERSION}"
end