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

require 'deployr/recipes/deploy/strategy/base'

module Deployr
  module Deploy
    module Strategy

      # An abstract superclass, which forms the base for all deployment
      # strategies which work by grabbing the code from the repository directly
      # from remote host. This includes deploying by checkout (the default),
      # and deploying by export.
      class Remote < Base
        # Executes the SCM command for this strategy and writes the REVISION
        # mark file to each host.
        def deploy!
          scm_run "#{command} && #{mark}"
        end

        def check!
          super.check do |d|
            d.remote.command(source.command)
          end
        end

        protected

          # Runs the given command, filtering output back through the
          # #handle_data filter of the SCM implementation.
          def scm_run(command, filter = nil)
            deployment.invoke_command(command, filter)
          end

          # An abstract method which must be overridden in subclasses, to
          # return the actual SCM command(s) which must be executed on each
          # target host in order to perform the deployment.
          def command
            raise NotImplementedError, "`command' is not implemented by #{self.class.name}"
          end

          # Returns the command which will write the identifier of the
          # revision being deployed to the REVISION file on each host.
          def mark
            "(echo #{revision} > #{deployment.release_path}/REVISION)"
          end
      end

    end
  end
end
