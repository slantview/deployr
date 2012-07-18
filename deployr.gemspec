# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'deployr/version'

Gem::Specification.new do |s|
  s.name        = "deployr"
  s.version     = Deployr::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Steve Rude"]
  s.email       = ["steve@slantview.com"]
  s.homepage    = "http://github.com/slantview/deployr"
  s.summary     = "Build management and deployment system."
  s.description = "Deployr is a build management software designed to make building, testing and deploying web based applications as seamless as possible."

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "deployr-ruby"

  s.add_development_dependency "rspec"

  s.files        = Dir.glob("{bin,lib}/**/*") + %w(README.md)
  s.executables  = ['deployr']
  s.require_path = 'lib'

  s.add_dependency('mixlib-config', '>= 1.0.0')
  s.add_dependency('mixlib-cli', '>= 1.0.0')
  s.add_dependency('mixlib-log', '>= 1.0.0')
  s.add_dependency('net-ssh', '>= 1.0.0')
  s.add_dependency('highline', '>= 1.0.0')

end
