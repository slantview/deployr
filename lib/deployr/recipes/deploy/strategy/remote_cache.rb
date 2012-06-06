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

require 'deployr/recipes/deploy/strategy/remote'

module Deployr
  module Deploy
    module Strategy

      # Implements the deployment strategy that keeps a cached checkout of
      # the source code on each remote server. Each deploy simply updates the
      # cached checkout, and then does a copy from the cached copy to the
      # final deployment location.
      class RemoteCache < Remote
        # Executes the SCM command for this strategy and writes the REVISION
        # mark file to each host.
        def deploy!
          update_repository_cache
          copy_repository_cache
        end

        def check!
          super.check do |d|
            d.remote.command("rsync") unless copy_exclude.empty?
            d.remote.writable(deployment.shared_path)
          end
        end

        private

          def repository_cache
            deployment.cached_dir || "cached-copy"
          end

          def update_repository_cache
            logger.trace "Updating the cached checkout on all servers."
            command = "if [ -d #{repository_cache} ]; then " +
              "#{source.sync(revision, repository_cache)}; " +
              "else #{source.checkout(revision, repository_cache)}; fi"
            scm_run(command)
          end

          def copy_repository_cache
            logger.trace "Copying the cached version to #{deployment.release_path}"

            #if copy_exclude.empty?
              deployment.invoke_command "cp -RPp #{repository_cache} #{deployment.release_path} && #{mark}"
            #else
            #  exclusions = copy_exclude.map { |e| "--exclude=\"#{e}\"" }.join(' ')
            #  puts exclusions.inspect
            #  deployment.invoke_command "rsync -lrpt #{exclusions} #{repository_cache}/ #{deployment.release_path} && #{mark}"
            #end
          end

          def copy_exclude
            @copy_exclude ||= Array(deployment.copy_exclude, [])
          end
      end

    end
  end
end
