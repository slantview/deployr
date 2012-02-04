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

require 'deployr/command'

module Deployr
  class CLI
    module Execute
      # Execute the command
      def execute
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
end