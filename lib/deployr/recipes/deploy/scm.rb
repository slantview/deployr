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
  module Deploy
    module SCM
      def self.new(scm, config={})
        scm_file = "deployr/recipes/deploy/scm/#{scm}"
        require(scm_file)

        scm_const = scm.to_s.capitalize.gsub(/_(.)/) { $1.upcase }
        if const_defined?(scm_const)
          const_get(scm_const).new(config)
        else
          raise Deployr::Error, "could not find `#{name}::#{scm_const}' in `#{scm_file}'"
        end
      rescue LoadError
        raise Deployr::Error, "could not find any SCM named `#{scm}'"
      end
    end
  end
end
