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
  class Command
    class EnvironmentEdit < Command
      
      banner "deployr environment edit ENVIRONMENT (options)"

      option :environment,
        :short => "-E ENVIRONMENT",
        :long => "--environment ENVIRONMENT",
        :description => "The environment to use.",
        :default => "production"
      
      def run
        
        @environment_name = @name_args[0]

        if @environment_name.nil?
          show_usage
          ui.fatal("You must specify an environment name")
          exit 1
        end
        ui.msg "Running Environment Edit..."
      end
    end
  end
end