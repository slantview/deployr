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

require 'deployr/dsl/base'
require 'deployr/mixin/from_file'
require 'deployr/application'
require 'deployr/hook'
require 'deployr/service'
require 'deployr/server'
require 'deployr/sshkey'
require 'deployr/deployment_runner'

module Deployr
  class Deployment

    include Deployr::DSL::Base
    include Deployr::Mixin::FromFile
    include Deployr::Deployment::Runner

    attr_accessor :id, :release_name, :config, :real_release
    attr_reader :app_object
    attr_reader :deploy_to
    attr_reader :releases_path
    attr_reader :current_path
    attr_reader :release_path
    attr_reader :shared_path
    attr_reader :shared_children
    attr_reader :cached_dir
    attr_reader :copy_exclude
    attr_reader :repository
    attr_reader :settings_file
    attr_reader :shared_settings_file
    attr_reader :site_dir
    attr_reader :site_url
    attr_reader :code_dir

    def initialize(config)
      @config = config
      @release_name = Time.now.utc.strftime("%Y%m%d%H%M%S")

      if @config[:deploy_file].nil?
        begin
          @config[:deploy_file] = find_deploy_file
        rescue Exception => e
          puts "Exception: #{e}"
        end
      end

      load_deploy_file

      @id = "#{@application.platform_name}_#{@release_name}"
      @hooks = (@hooks.nil? ? @application.hooks : @hooks.merge!(@application.hooks))
      @services = (@services.nil? ? @application.services : @services.merge!(@application.services))
      @servers = (@servers.nil? ? @application.servers : @servers.merge!(@application.servers))
      @ssh_keys = (@ssh_keys.nil? ? @application.ssh_keys : @ssh_keys.merge!(@application.hooks))

      # TODO fixme so we don't have to do this. (it has to do with the DSL + @application instance name being the same.)
      @app_object = @application.dup
      # END TODO

      @options = @app_object.options
      @deploy_to = @options[:deploy_to]
      @releases_path = File.join(@deploy_to, @options[:releases_dir])
      @current_path  = File.join(@deploy_to, @options[:current_dir])
      @release_path = File.join(@releases_path, @release_name)
      @shared_path = File.join(@deploy_to, @options[:shared_dir])
      @cached_dir = File.join(@shared_path, @options[:cached_dir])
      @shared_children = [ @options[:shared_config_dir], @options[:shared_files_dir] ]
      @copy_exclude = @options[:copy_exclude]
      @repository = @options[:repository]
      @settings_file = @options[:settings_file]
      @site_url = @options[:site_url]
      @code_dir = @options[:code_dir] || ''
      @site_dir = @options[:site_dir] || File.join(@code_dir, "sites/default")
    end

    def invoke_command(command)
      use_sudo = @options[:use_sudo]
      output = Hash.new
      @servers.each do |name, server|
        puts "Invoking #{command} on #{name.to_s}"
        output[name] = server.exec "#{command}"
      end
      output
    end

    def cleanup_old_releases
      self.invoke_command("cd #{@releases_path} && rm -rf `ls -tr |head -n -5`")
    end

    def invoke_local_command(command)
      puts "Invoking (locally): #{command.inspect}"
      output_on_stdout = nil
      elapsed = Benchmark.realtime do
        output_on_stdout = `#{command}`
      end
      if $?.to_i > 0 # $? is command exit code (posix style)
        raise Deployr::LocalArgumentError, "Command #{command} returned status code #{$?}"
      end
      puts "command finished in #{(elapsed * 1000).round}ms"
      output_on_stdout
    end

    def load_deploy_file
      begin
        self.from_file(@config[:deploy_file])
        #self.instance_eval(IO.read(@config[:deploy_file]), @config[:deploy_file], 1)
      rescue IOError => e
        puts "Unable to load deployment file #{@config[:deploy_file]}: #{e}"
        exit -1
      end
    end

    def find_deploy_file
      @deploy_file = nil
      full_path = Dir.pwd.split(File::SEPARATOR)
      (full_path.length - 1).downto(0) do |i|
        candidate_file = File.join(full_path[0..i] + ["Deployfile"])
        if File.exist?(candidate_file) && File.readable?(candidate_file)
          @deploy_file = candidate_file
          break
        else
            raise IOError, "File doesn't exist or is unreadable."
        end
      end
      @deploy_file
    end
  end
end
