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

require 'deployr/recipes/deploy'

module Deployr
  class Command
    class Deploy < Command

      banner "deployr deploy (options)"

      def run
        ui.msg "Deploy#run"
        @source = Deployr::Deploy::SCM.new(@application.options[:scm], deployment)
        @strategy = Deployr::Deploy::Strategy.new(@application.options[:strategy], deployment, @source)
        @deployment.real_release = @source.query_revision(@source.head) { |cmd| @deployment.invoke_local_command(cmd) }
        @deployment.start(self)
      end

      def finish
        ui.msg "Cleaning up old releases."
        @deployment.cleanup_old_releases
        ui.msg "Deploy complete."
      end
    end
  end
end
