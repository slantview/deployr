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
    class ServerEdit < Command
      
      banner "deployr server edit SERVER (options)"
      
      def run

        @server_name = @name_args[0]

        if @server_name.nil?
          show_usage
          ui.fatal("You must specify a server name")
          exit 1
        end
        ui.msg "Running Server Edit (#{@server_name})..."
      end
    end
  end
end