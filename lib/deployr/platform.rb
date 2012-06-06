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

require 'deployr/dsl/base'

module Deployr
  class Platform
    include Deployr::DSL::Base

    def initialize(*args)
      self.class.instance_variables.each do |key|
        value = self.class.instance_variable_get(key)
        self.instance_variable_set(key, value)
      end
    end

    def module_get(name)
      Kernel.const_get("#{self.class.to_s}::#{name}")
    end
  end
end
