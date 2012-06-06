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
  class Hook

    attr_accessor :name
    attr_accessor :options

    def initialize(name, options)
      @name, @options = name, options
      puts "I am a hook: #{name}"

      @options.each do |key, val|
        case key.to_sym
        when :start_command
          @start_command = val
          @options.delete(key)
        when :stop_command
          @stop_command = val
          @options.delete(key)
        when :restart_command
          @restart_command = val
          @options.delete(key)
        end
      end
    end
  end
end
