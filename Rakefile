$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "deployr/version"
 
task :build do
  system "gem build deployr.gemspec"
end

task :install do
  Rake::Task["build"].execute
  system "sudo gem install deployr-#{Deployr::VERSION}"
end
  
task :release => :build do
  system "gem push deployr-#{Bunder::VERSION}"
end

task :default do
  Rake::Task["install"].execute
end
