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

require 'deployr/dsl/hook_dsl'
require 'deployr/dsl/key_dsl'
require 'deployr/dsl/platform_dsl'
require 'deployr/dsl/service_dsl'

module Deployr
  class Platform
    include Deployr::HookDSL
    include Deployr::KeyDSL
    include Deployr::PlatformDSL
    include Deployr::ServiceDSL

    def show_info
      puts "Hooks: "
      puts @hooks
      puts "Keys: "
      puts @keys
      puts "Platforms: "
      puts @platforms
      puts "Services: "
      puts @services
    end
  end
end
