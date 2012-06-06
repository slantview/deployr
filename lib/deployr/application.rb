#
# Author:: Steve Rude (<steve@slantview.com>)
# Copyright:: Copyright (c) 2012 Slantview Media.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'deployr/platform_loader'

module Deployr
  class Application

    include Deployr::Mixin::FromFile

    attr_accessor :name, :options, :platform_name, :platform, :hooks, :services, :servers, :ssh_keys

    def initialize(name, options = {}, config = {})
      @name, @application_options, @config = name, options, config
      load_platforms

      platform_klass = platform_loader.convert_to_klass(@application_options[:platform])
      @platform = platform_klass.new

      @platform_name = @platform.platform_name
      @options = @platform.options || {}
      @options.merge!(@application_options)
      @hooks = @platform.class.hooks || {}
      @services = @platform.class.services || {}
      @servers = @platform.class.servers || {}
      @ssh_keys = @platform.class.ssh_keys || {}

    end

    def load_platforms
      @platforms_loaded ||= platform_loader.load_platforms
      true
    end

    def platform_loader
      @platform_loader || Deployr::PlatformLoader.new(File.dirname(@config[:config_file]))
    end

  end
end
