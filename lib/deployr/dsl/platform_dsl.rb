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

#Platform
#Key
#Hook
#Service

module Deployr
  module PlatformDSL
    module ClassMethods
      # Add a platform definition to a Platform
      #
      # === Parameters
      # name<Symbol>:: The name of the platform to add.
      # args<Hash>:: A hash of arguments specifying how it should be parsed.
      # === Returns
      # true:: Always returns true.
      def platform(name, args)
        @platforms ||= {}
        raise(ArgumentError, "Platform name must be a symbol") unless name.kind_of?(Symbol)
        @platforms[name.to_sym] = args
      end

      # Get the hash of current platforms.
      #
      # === Returns
      # @platforms<Hash>:: The current platforms hash.
      def platforms
        @platforms ||= {}
        @platforms
      end

      # Set the current platforms hash
      #
      # === Parameters
      # val<Hash>:: The hash to set the platforms to
      # === Returns
      # @platforms<Hash>:: The current platforms hash.
      def platforms=(val)
        raise(ArgumentError, "Platforms must recieve a hash") unless val.kind_of?(Hash)
        @platforms = val
      end
    end

    def self.included(receiver)
      receiver.extend(Deployr::PlatformDSL::ClassMethods)
    end

  end
end
