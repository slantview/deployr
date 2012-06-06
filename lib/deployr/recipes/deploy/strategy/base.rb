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

require 'benchmark'
require 'deployr/recipes/deploy/dependencies'

module Deployr
  module Deploy
    module Strategy

      # This class defines the abstract interface for all Capistrano
      # deployment strategies. Subclasses must implement at least the
      # #deploy! method.
      class Base
        attr_reader :deployment, :source

        # Instantiates a strategy with a reference to the given configuration.
        def initialize(deployment, source)
          @deployment, @source = deployment, source
        end

        # Executes the necessary commands to deploy the revision of the source
        # code identified by the +revision+ variable. Additionally, this
        # should write the value of the +revision+ variable to a file called
        # REVISION, in the base of the deployed revision. This file is used by
        # other tasks, to perform diffs and such.
        def deploy!
          raise NotImplementedError, "`deploy!' is not implemented by #{self.class.name}"
        end

        # Performs a check on the remote hosts to determine whether everything
        # is setup such that a deploy could succeed.
        def check!
          Dependencies.new(deployment) do |d|
            d.remote.directory(deployment.releases_path).or("`#{deployment.releases_path}' does not exist. Please run `cap deploy:setup'.")
            d.remote.writable(deployment.deploy_to).or("You do not have permissions to write to `#{deployment.deploy_to}'.")
            d.remote.writable(deployment.releases_path).or("You do not have permissions to write to `#{deployment.releases_path}'.")
          end
        end

        protected

          # This is to allow helper methods like "run" and "put" to be more
          # easily accessible to strategy implementations.
          def method_missing(sym, *args, &block)
            if deployment.respond_to?(sym)
              deployment.send(sym, *args, &block)
            else
              super
            end
          end

          # A wrapper for Kernel#system that logs the command being executed.
          def system(*args)
            cmd = args.join(' ')
            result = nil
            if RUBY_PLATFORM =~ /win32/
              cmd = cmd.split(/\s+/).collect {|w| w.match(/^[\w+]+:\/\//) ? w : w.gsub('/', '\\') }.join(' ') # Split command by spaces, change / by \\ unless element is a some+thing://
              cmd.gsub!(/^cd /,'cd /D ') # Replace cd with cd /D
              cmd.gsub!(/&& cd /,'&& cd /D ') # Replace cd with cd /D
              logger.trace "Invoking (locally): #{cmd}"
              elapsed = Benchmark.realtime do
                result = super(cmd)
              end
            else
              logger.trace "Invoking (locally): #{cmd}"
              elapsed = Benchmark.realtime do
                result = super
              end
            end

            logger.trace "command finished in #{(elapsed * 1000).round}ms"
            result
          end

        private

          def logger
            @logger ||= Deployr::UI.new(STDOUT, STDERR, STDIN, {})
          end

          # The revision to deploy. Must return a real revision identifier,
          # and not a pseudo-id.
          def revision
            deployment.real_release
          end
      end

    end
  end
end
