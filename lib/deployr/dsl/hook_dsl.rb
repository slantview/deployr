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
  module HookDSL
    module ClassMethods
      # Add a hook to a platform
      #
      # === Parameters
      # name<Symbol>:: The name of the hook to add.
      # args<Hash>:: A hash of arguments specifying how it should be parsed.
      # === Returns
      # true:: Always returns true.
      def hook(name, args)
        @hooks ||= {}
        raise(ArgumentError, "Hook name must be a symbol") unless name.kind_of?(Symbol)
        puts "Found hook (#{name.to_s})"
        @hooks[name.to_sym] = args
        puts @hooks
      end

      # Get the hash of current hooks.
      #
      # === Returns
      # @hooks<Hash>:: The current hooks hash.
      def hooks
        @hooks ||= {}
        puts "Founds hooks: "
        @hooks
      end

      # Set the current hooks hash
      #
      # === Parameters
      # val<Hash>:: The hash to set the hooks to
      # === Returns
      # @hooks<Hash>:: The current hooks hash.
      def hooks=(val)
        raise(ArgumentError, "Hooks must recieve a hash") unless val.kind_of?(Hash)
        @hooks = val
      end
    end

    def self.included(receiver)
      receiver.extend(Deployr::HookDSL::ClassMethods)
    end

  end
end
