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

require 'deployr/command_loader'
require 'deployr/deployment'
require 'deployr/mixin/convert_to_class'
require 'net/http'
require 'json'

module Deployr
  class Command

    include Mixlib::CLI
    extend Deployr::Mixin::ConvertToClassName

    attr_accessor :name_args
    attr_accessor :ui
    attr_accessor :deployment
    attr_accessor :command_name
    attr_accessor :current_app

    def self.ui
      @ui ||= Deployr::UI.new(STDOUT, STDERR, STDIN, config)
    end

    def self.config
      @config ||= Deployr::Config
    end

    def initialize(argv={})
      super()
      @config = Deployr::Config
      @ui = Deployr::UI.new(STDOUT, STDERR, STDIN, config)

      command_name_words = self.class.snake_case_name.split('_')

      # Mixlib::CLI ignores the embedded name_args
      @name_args = parse_options(argv)
      @name_args.delete(command_name_words.join('-'))
      @name_args.reject! { |name_arg| command_name_words.delete(name_arg) }

      # We have extra logic to handle the case that command name words could be joined by an underscore
      command_name_words = command_name_words.join('_')
      @command_name = command_name_words
      @name_args.reject! { |name_arg| command_name_words == name_arg }

      if config[:help]
        ui.msg opt_parser
        exit 1
      end
    end

    def self.category(new_category)
      @category = new_category
    end

    def self.subcommand_category
      @category || snake_case_name.split('_').first unless unnamed?
    end

    def self.snake_case_name
      convert_to_snake_case(name.split('::').last) unless unnamed?
    end

    def self.common_name
      snake_case_name.split('_').join(' ')
    end

    def self.inherited(subclass)
      unless subclass.unnamed?
        commands[subclass.snake_case_name] = subclass
      end
    end

    def self.run(args, options={})
      load_commands

      command_class = command_class_from(args)
      command_class.options = options.merge!(command_class.options)
      command_class.load_deps unless want_help?(args)

      instance = command_class.new(args)
      instance.configure_deployr
      instance.load_deployment
      instance.run_with_pretty_exceptions
    end

    def self.command_class_from(args)
      command_words = args.select {|arg| arg =~ /^(([[:alnum:]])[[:alnum:]\_\-]+)$/ }

      command_class = nil

      while ( !command_class ) && ( !command_words.empty? )
        snake_case_class_name = command_words.join("_")
        unless command_class = commands[snake_case_class_name]
          command_words.pop
        end
      end
      # see if we got the command as e.g., deployr node-list
      command_class ||= commands[args.first.gsub('-', '_')]
      command_class || command_not_found!(args)
    end

    # Load all the sub-commands
    def self.load_commands
       @commands_loaded ||= command_loader.load_commands
      true
    end

    def self.command_loader
      @command_loader || Deployr::CommandLoader.new(deployr_config_dir)
    end

    def self.reset_commands!
      @@commands = {}
      @commands_by_category = nil
    end

    def self.commands
      @@commands ||= {}
    end

    def self.deps(&block)
      @dependency_loader = block
    end

    def self.load_deps
      @dependency_loader && @dependency_loader.call
    end

    # :nodoc:
    # Error out and print usage. probably becuase the arguments given by the
    # user could not be resolved to a subcommand.
    def self.command_not_found!(args)
      unless want_help?(args)
        ui.fatal("Cannot find sub command for: '#{args.join(' ')}'")
      end

      category_commands = guess_category(args) ? guess_category(args) : nil
      list_commands(category_commands)

      exit 10
    end

    @@deployr_config_dir = nil

    # search upward from current_dir until deploy directory is found
    def self.deployr_config_dir
      if @@deployr_config_dir.nil? # share this with subclasses
        @@deployr_config_dir = false
        full_path = Dir.pwd.split(File::SEPARATOR)
        (full_path.length - 1).downto(0) do |i|
          candidate_directory = File.join(full_path[0..i] + [".deployr"])
          if File.exist?(candidate_directory) && File.directory?(candidate_directory)
            @@deployr_config_dir = candidate_directory
            break
          end
        end
      end
      @@deployr_config_dir
    end

    def self.list_commands(preferred_category=nil)
      load_commands

      category_desc = preferred_category ? preferred_category + " " : ''
      ui.msg "Available #{category_desc}commands: (for details, deployr SUB-COMMAND --help)\n\n"

      if preferred_category && commands_by_category.key?(preferred_category)
        commands_to_show = {preferred_category => commands_by_category[preferred_category]}
      else
        commands_to_show = commands_by_category
      end

      commands_to_show.sort.each do |category, subcommands|
        next if category =~ /deprecated/i
        ui.msg "--- #{category.upcase} COMMANDS ---"
        subcommands.each do |subcommand|
          ui.msg commands[subcommand].banner if commands[subcommand]
        end
        ui.msg ""
      end
    end

    def self.commands_by_category
      unless @commands_by_category
        @commands_by_category = Hash.new { |hash, key| hash[key] = [] }
        commands.each { |snake_cased, klass| @commands_by_category[klass.command_category] << snake_cased }
      end
      @commands_by_category
    end

    def self.command_category
      @category || snake_case_name.split('_').first unless unnamed?
    end

    def self.guess_category(args)
      category_words = args.select {|arg| arg =~ /^(([[:alnum:]])[[:alnum:]\_\-]+)$/ }
      category_words.map! {|w| w.split('-')}.flatten!
      matching_category = nil
      while (!matching_category) && (!category_words.empty?)
        candidate_category = category_words.join(' ')
        matching_category = candidate_category if commands_by_category.key?(candidate_category)
        matching_category || category_words.pop
      end
      matching_category
    end

    def self.want_help?(args)
      (args.any? { |arg| arg =~ /^(:?(:?\-\-)?help|\-h)$/})
    end

    def self.unnamed?
      name.nil? || name.empty?
    end

    def parse_options(args)
      super
    rescue OptionParser::InvalidOption => e
      puts "Error: " + e.to_s
      puts "#show_usage"
      show_usage
      exit(1)
    end

    def configure_deployr
      ui.debug "Starting Configure."

      # Set defaults
      config[:version] = Deployr::VERSION
      config[:log_level] = :debug
      config[:color] = false
      config[:deploy_file] = nil
      config[:help] = false

      unless config[:config_file]
        if self.class.deployr_config_dir
          candidate_config = File.expand_path('deployr.rb',self.class.deployr_config_dir)
          config[:config_file] = candidate_config if File.exist?(candidate_config)
        end
        # If we haven't set a config yet and $HOME is set, and the home
        # deployr.rb exists, use it:
        if (!config[:config_file]) && ENV['HOME'] && File.exist?(File.join(ENV['HOME'], '.deployr', 'deployr.rb'))
          config[:config_file] = File.join(ENV['HOME'], '.deployr', 'deployr.rb')
        end
      end
      read_config_file(config[:config_file])
    end

    def read_config_file(config_file=nil)
      Deployr::Config.from_file(config_file) unless config_file.nil? && !File.exists?(config_file)
    end

    def load_deployment
      @deployment ||= Deployr::Deployment.new(config)
      @deployment.load_deploy_file
      # TODO: fix this shit.  shouldn't need this here.
      @current_app = @deployment.app_object

      # Now this is a little weird, we want to extend deployment so that it has
      # the functionality defined in the platform.  This can be extended also by
      # the application instance because of the Deployfile.
      klass_name = self.class.name.split('::').last
      if @current_app.platform.class.const_defined?(klass_name)
        platform_command_klass = @current_app.platform.class.const_get(klass_name)
        self.extend(platform_command_klass)
      end
    end

    def show_usage
      ui.msg("USAGE: " + self.opt_parser.to_s)
    end

    def self.deployment
      @deployment ||= Deployr::Deployment.new(config)
    end

    def run_with_pretty_exceptions
      unless self.respond_to?(:run)
        ui.error "You need to add a #run method to your deployr command before you can use it"
      end
      #enforce_path_sanity
      run
    rescue Exception => e
      raise if config[:verbosity] == 2
      humanize_exception(e)
      exit 100
    end

    def humanize_exception(e)
      case e
      when SystemExit
        raise # make sure exit passes through.
      when Net::HTTPServerException, Net::HTTPFatalError
        humanize_http_exception(e)
      when Errno::ECONNREFUSED, Timeout::Error, Errno::ETIMEDOUT, SocketError
        ui.error "Network Error: #{e.message}"
        ui.info "Check your deployr configuration and network settings"
      when NameError, NoMethodError
        ui.error "deployr encountered an unexpected error"
        ui.info  "This may be a bug in the '#{self.class.common_name}' deployr command or plugin"
        ui.info  "Please collect the output of this command with the `-VV` option before filing a bug report."
        ui.info  "Exception: #{e.class.name}: #{e.message}"
      else
        ui.error "#{e.class.name}: #{e.message}"
      end
    end

    def humanize_http_exception(e)
      response = e.response
      case response
      when Net::HTTPUnauthorized
        ui.error "Failed to authenticate to #{server_url} as #{username} with key #{api_key}"
        ui.info "Response:  #{format_rest_error(response)}"
      when Net::HTTPForbidden
        ui.error "You authenticated successfully to #{server_url} as #{username} but you are not authorized for this action"
        ui.info "Response:  #{format_rest_error(response)}"
      when Net::HTTPBadRequest
        ui.error "The data in your request was invalid"
        ui.info "Response: #{format_rest_error(response)}"
      when Net::HTTPNotFound
        ui.error "The object you are looking for could not be found"
        ui.info "Response: #{format_rest_error(response)}"
      when Net::HTTPInternalServerError
        ui.error "internal server error"
        ui.info "Response: #{format_rest_error(response)}"
      when Net::HTTPBadGateway
        ui.error "bad gateway"
        ui.info "Response: #{format_rest_error(response)}"
      when Net::HTTPServiceUnavailable
        ui.error "Service temporarily unavailable"
        ui.info "Response: #{format_rest_error(response)}"
      else
        ui.error response.message
        ui.info "Response: #{format_rest_error(response)}"
      end
    end
  end
end
