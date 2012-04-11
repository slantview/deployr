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
  module ServiceDSL
    module ClassMethods
      # Add a service definition to a Platform
      #
      # === Parameters
      # name<Symbol>:: The name of the service to add.
      # args<Hash>:: A hash of arguments specifying how it should be parsed.
      # === Returns
      # true:: Always returns true.
      def service(name, args)
        @services ||= {}
        raise(ArgumentError, "Service name must be a symbol") unless name.kind_of?(Symbol)
        @services[name.to_sym] = args
      end

      # Get the hash of current services.
      #
      # === Returns
      # @services<Hash>:: The current services hash.
      def services
        @services ||= {}
        @services
      end

      # Set the current services hash
      #
      # === Parameters
      # val<Hash>:: The hash to set the services to
      # === Returns
      # @services<Hash>:: The current services hash.
      def services=(val)
        raise(ArgumentError, "Services must recieve a hash") unless val.kind_of?(Hash)
        @services = val
      end
    end

    def self.included(receiver)
      receiver.extend(Deployr::ServiceDSL::ClassMethods)
    end

  end
end
