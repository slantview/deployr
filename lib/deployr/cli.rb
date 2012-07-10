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

require 'rubygems'
require 'mixlib/cli'
require 'deployr'
#require 'deployr/cli/execute'


module Deployr
  # The CLI class encapsulates the command line functionality.
  class CLI
    # include Mixlib::CLI for parsing functionality
    include Mixlib::CLI

    # Add our mix-ins
    #include Execute

    NO_COMMAND_GIVEN = "You need to pass a sub-command (e.g., deployr SUB-COMMAND)\n"

    banner "Usage: deployr sub-command (options)"

    option :config_file,
      :short => "-c CONFIG",
      :long => "--config CONFIG",
      :default => nil,
      :description => "The configuration file to use."

    option :environment,
      :short => "-E ENVIRONMENT",
      :long => "--environment ENVIRONMENT",
      :default => :dev,
      :description => "The environment file to use.",
      :proc => Proc.new { |l| l.to_sym }

    option :application,
      :short => "-a APPLICATION",
      :long => "--application APPLICATION",
      :default => :default,
      :description => "The application to use. Defaults to first listed if not supplied.",
      :proc => Proc.new { |l| l.to_sym }


    option :log_level,
      :short => "-l LEVEL",
      :long => "--log_level LEVEL",
      :description => "Set the log level (debug, info, warn, error, fatal)",
      :proc => Proc.new { |l| l.to_sym }

    verbosity_level = 0
    option :verbosity,
      :short => '-v',
      :long => '--verbose',
      :description => "More verbose output.  Use multiple times (-vv) for additional verbosity.",
      :proc => Proc.new { verbosity_level += 1 },
      :default => 0

    option :version,
      :short => "-V",
      :long => "--version",
      :description => "Show the current version and exit.",
      :boolean => true,
      :proc => lambda {|v| puts "Deployr: #{::Deployr::VERSION}"},
      :exit => 0

    option :help,
      :short => "-h",
      :long => "--help",
      :description => "Show this message",
      :on => :tail,
      :boolean => true,
      :show_options => true,
      :exit => 0

    def validate_and_parse_options
      # Checking ARGV validity *before* parse_options because parse_options
      # mangles ARGV in some situations
      if no_command_given?
        print_help_and_exit(1, NO_COMMAND_GIVEN)
      elsif no_subcommand_given?
        if (want_help? || want_version?)
          print_help_and_exit
        else
          print_help_and_exit(2, NO_COMMAND_GIVEN)
        end
      end
    end

    def no_subcommand_given?
      ARGV[0] =~ /^-/
    end

    def no_command_given?
      ARGV.empty?
    end

    def want_help?
      ARGV[0] =~ /^(--help|-h)$/
    end

    def want_version?
      ARGV[0] =~ /^(--version|-V)$/
    end

    def print_help_and_exit(exitcode=1, fatal_message=nil)
      Deployr::Log.error(fatal_message) if fatal_message

      begin
        self.parse_options
      rescue OptionParser::InvalidOption => e
        puts "#{e}\n"
      end
      puts self.opt_parser
      puts
      Deployr::Command.list_commands
      exit exitcode
    end

    # Execute the command
    def run
      Mixlib::Log::Formatter.show_time = false
      validate_and_parse_options
      quiet_traps
      execute!
      exit 0
    end

    # Internal execute command
    def execute!
      Deployr::Command.run(ARGV, options)
    end

    private
    def quiet_traps
      trap("TERM") do
        exit 1
      end

      trap("INT") do
        exit 2
      end
    end
  end
end
