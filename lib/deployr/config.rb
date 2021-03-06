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

require 'rubygems'
require 'mixlib/config'

module Deployr
  class Config
    extend(Mixlib::Config)

    configure do |c|
      c[:version] = Deployr::VERSION
      c[:log_level] = :debug
      c[:color] = true
      c[:deploy_file] = nil
      c[:help] = false

      # Set global $DEBUG to true
      #$DEBUG = (config[:log_level] == :debug) ? true : false
    end
  end
end
