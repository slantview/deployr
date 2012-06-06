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
  module Init
    class Setup
      def initialize(deployment, application, ui)
        @deployment, @ui = deployment, ui
      end

      def create_directories
        dirs = [@deployment.deploy_to, @deployment.releases_path, @deployment.shared_path]
        dirs += @deployment.shared_children.map { |d| File.join(@deployment.shared_path, d) }
        @deployment.servers.each do |name, server|
          server.connect
          @ui.info "Creating directories: #{dirs.join(' ')}"
          server.exec "mkdir -p #{dirs.join(' ')}"
          server.exec "chmod g+w #{dirs.join(' ')}"
        end
      end

      def test_directories
        dirs = [@deployment.deploy_to, @deployment.releases_path, @deployment.shared_path]
        dirs += @deployment.shared_children.map { |d| File.join(@deployment.shared_path, d) }
        #TODO test directories
      end
    end
  end
end
