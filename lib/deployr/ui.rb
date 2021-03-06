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

module Deployr
  class UI

    def initialize(stdout, stderr, stdin, *config)
      @stdout, @stderr, @stdin, @config = stdout, stderr, stdin, config
    end

    def highline
      @highline ||= begin
        require 'highline'
        HighLine.new
      end
    end

    def msg(message)
      @stdout.puts message
    end

    alias :info :msg
    alias :trace :msg

    # Prints a msg to stderr. Used for warn, error, and fatal.
    def err(message)
      @stderr.puts message
    end

    # Print a warning message
    def warn(message)
      err("#{color('WARNING:', :yellow, :bold)} #{message}")
    end

    # Print an error message
    def error(message)
      err("#{color('ERROR:', :red, :bold)} #{message}")
    end

    # Print a message describing a fatal error.
    def fatal(message)
      err("#{color('FATAL:', :red, :bold)} #{message}")
    end

    def debug(message)
      err message if $DEBUG
    end

    def color(string, *colors)
      if color?
        highline.color(string, *colors)
      else
        string
      end
    end

    # Should colored output be used? For output to a terminal, this is
    # determined by the value of `config[:color]`. When output is not to a
    # terminal, colored output is never used
    def color?
      @config[:color] && stdout.tty?
      true
    end

    def ask(*args, &block)
      highline.ask(*args, &block)
    end

    def list(*args)
      highline.list(*args)
    end

    # Formats +data+ using the configured presenter and outputs the result
    # via +msg+. Formatting can be customized by configuring a different
    # presenter. See +use_presenter+
    def output(data)
      msg @presenter.format(data)
    end

  end
end
