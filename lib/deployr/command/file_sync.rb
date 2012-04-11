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
    class FileSync < Command

      banner "deployr file sync (options)"

      option :environment,
        :short => "-E ENVIRONMENT",
        :long => "--env ENVIRONMENT",
        :description => "The environment to use.",
        :default => "development"

      option :override_local,
        :short => "-O",
        :long => "--override",
        :description => "Override local files.",
        :default => false

      def run
        ui.msg "Running File Sync..."
      end
    end
  end
end
