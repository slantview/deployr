require 'rubygems'
require 'mixlib/config'

module Deployr
  class Config
    extend(Mixlib::Config)
    
    configure do |c|
      c[:version] = Deployr::VERSION
      c[:log_level] = 'debug'
    end
  end
end