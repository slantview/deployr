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
require 'deployr/environment'
require 'deployr/deployment_runner'

module Deployr
  class Deployment

    include Deployr::DSL::Base
    include Deployr::Mixin::FromFile
    include Deployr::Deployment::Runner

    attr_accessor :id, :release_name, :config, :real_release, :pointer_moved, :options
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
    attr_reader :app_env

    def initialize(config)
      @config = config
      @release_name = Time.now.utc.strftime("%Y%m%d%H%M%S")
      @pointer_moved = false

      if @config[:deploy_file].nil?
        begin
          @config[:deploy_file] = find_deploy_file
        rescue Exception => e
          puts "Exception: #{e}"
        end
      end

      load_deploy_file

      # TODO fixme so we don't have to do this. (it has to do with the DSL + @application instance name being the same.)
      if @applications.length == 1 || @config[:application] == :default
        @app_object = @applications[@applications.keys.pop]
      else
        if @applications.has_key?(@config[:application])
          @app_object = @applications[@config[:application]]
        else
          raise Deployr::Error, "Unable to find application '#{@config[:application]}'."
        end
      end

      @options = @app_object.options.dup
      # END TODO

      # Merge environments last
      if not @environments.has_key?(@config[:environment])
        raise Deployr::Error, "Unable to find environment #{@config[:environment]}"
      end
      # Get the environment from defaults
      @app_env = @environments[@config[:environment]]
      @options[:deploy_to] = @app_env.options[:deploy_to]

      # Now that we have the environment, override defaults with environment variables.
      merge_instance_variables(@app_env.options)

      @id = "#{@app_object.platform_name}_#{@release_name}"
      @hooks = (@hooks.nil? ? @app_object.hooks : @hooks.merge!(@app_object.hooks))
      @services = (@services.nil? ? @app_object.services : @services.merge!(@app_object.services))
      @servers = (@servers.nil? ? @app_object.servers : @servers.merge!(@app_object.servers))
      
      @deploy_to = @options.has_key?(:deploy_to) ? @options[:deploy_to] : "/var/www/#{app_object.name}"
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

      # TODO: Cleanup the inheritance issue with Application > Environment > Server, and 
      # find a cleaner way to apply inheritance on each variable.
      @servers.each do |name, server|
        %w{ user key }.each do |key|
          sym_key = "ssh_#{key}".to_sym
          if @app_env.options.has_key?(sym_key)
            @servers[name].instance_variable_set("@#{key}", @app_env.options[sym_key])
          elsif @app_object.options.has_key?(sym_key)
            @servers[name].instance_variable_set("@#{key}", @app_object.options[sym_key])
          end

        end
      end
    end

    def invoke_command(command, filter = nil)
      use_sudo = @options[:use_sudo]
      output = Hash.new
      find_servers_for_task(filter).each do |name, server|
        puts "Invoking #{command} on #{name.to_s}"
        output[name] = server.exec "#{command}"
      end
      output
    end

    def find_servers_for_task(filter = nil)
      server_array = Hash.new
      if !@config[:environment].nil?
        @servers.each do |name, server|
          if server.options[:environment] == @config[:environment]
            if not filter.nil? && server.has_service?(filter)
              puts "Found Server: #{name} (#{server}) ENVIRONMENT=#{server.options[:environment]}"
              server_array[name] = server
            end
          end
        end
      end
      server_array
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
          raise Deployr::Error, "File doesn't exist or is unreadable."
        end
      end
      @deploy_file
    end

    def merge_instance_variables(options = {}, instance = nil)
      instance = self if instance.nil?
      options.each do |key, value|
        instance.instance_variable_set("@#{key}", value)
      end
      if not options.has_key?(:deploy_to)
        puts "ASSIGN DEPLOY_TO"
        instance.deploy_to = options[:deploy_to]
        puts instance.inspect
      end
    end
  end
end
