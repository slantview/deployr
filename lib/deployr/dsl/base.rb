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
  module DSL
    module Base
      # Load the ClassMethods upon include.
      def self.included(base) #:nodoc
        base.extend self
      end

      #module ClassMethods
        attr_reader :platform_name, :applications, :options, :hooks, :platforms, :services, :servers, :ssh_keys

        # Add an Application instance
        #
        # === Parameters
        # name<Symbol>:: The name of the Application to add.
        # args<Hash>:: A hash of arguments specifying how it should be parsed.
        # === Returns
        # true:: Always returns true.
        def application(name, args)
          @applications ||= {}
          raise(ArgumentError, "Application name must be a symbol") unless name.kind_of?(Symbol)
          @applications[name.to_sym] = Deployr::Application.new(name, args, @config)
        end

        # Get the hash of current applications.
        #
        # === Returns
        # @applications<Hash>:: The current applications hash.
        def applications
          @applications ||= {}
          @applications
        end

        # Add a hook definition to a hook
        #
        # === Parameters
        # name<Symbol>:: The name of the hook to add.
        # args<Hash>:: A hash of arguments specifying how it should be parsed.
        # === Returns
        # true:: Always returns true.
        def hook(name, args)
          @hooks ||= {}
          raise(ArgumentError, "Hook name must be a symbol") unless name.kind_of?(Symbol)
          @hooks[name.to_sym] = args
        end

        # Get the hash of current hooks.
        #
        # === Returns
        # @hooks<Hash>:: The current hooks hash.
        def hooks
          @hooks ||= {}
          @hooks
        end

        # Set the current hooks hash
        #
        # === Parameters
        # val<Hash>:: The hash to set the hooks to
        # === Returns
        # @hooks<Hash>:: The current hooks hash.
        def hooks=(val)
          raise(ArgumentError, "hooks must recieve a hash") unless val.kind_of?(Hash)
          @hooks = val
        end

        # Add a platform definition to a Platform
        #
        # === Parameters
        # name<Symbol>:: The name of the platform to add.
        # args<Hash>:: A hash of arguments specifying how it should be parsed.
        # === Returns
        # true:: Always returns true.
        def platform(name, args)
          raise(ArgumentError, "Platform name must be a symbol") unless name.kind_of?(Symbol)
          @platform_name = name.to_sym
          @options = args
        end

        # Get the hash of current hooks.
        #
        # === Returns
        # @hooks<Hash>:: The current hooks hash.
        #def options
        #  @options ||= {}
        #  @options
        #end

        # Get the hash of current hooks.
        #
        # === Returns
        # @hooks<Hash>:: The current hooks hash.
        #def alias
        #  @alias ||= Symbol.new
        #  @alias
        #end

        # Add a service definition to a service
        #
        # === Parameters
        # name<Symbol>:: The name of the service to add.
        # args<Hash>:: A hash of arguments specifying how it should be parsed.
        # === Returns
        # true:: Always returns true.
        def service(name, args)
          @services ||= {}
          raise(ArgumentError, "Service name must be a symbol") unless name.kind_of?(Symbol)
          @services[name.to_sym] = Deployr::Service.new(name, args, @config)
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

        # Add a server definition to a server
        #
        # === Parameters
        # name<Symbol>:: The name of the server to add.
        # args<Hash>:: A hash of arguments specifying how it should be parsed.
        # === Returns
        # true:: Always returns true.
        def server(name, args)
          @servers ||= {}
          raise(ArgumentError, "Server name must be a symbol") unless name.kind_of?(Symbol)
          @servers[name.to_sym] = Deployr::Server.new(name, args, @config)
        end

        # Get the hash of current servers.
        #
        # === Returns
        # @deploy_options[:servers]<Hash>:: The current servers hash.
        def servers
          @servers ||= {}
          @servers
        end

        # Set the current servers hash
        #
        # === Parameters
        # val<Hash>:: The hash to set the servers to
        # === Returns
        # @deploy_options[:servers]<Hash>:: The current servers hash.
        def servers=(val)
          raise(ArgumentError, "servers must recieve a hash") unless val.kind_of?(Hash)
          @servers = val
        end

        # Add a server definition to a server
        #
        # === Parameters
        # name<Symbol>:: The name of the server to add.
        # args<Hash>:: A hash of arguments specifying how it should be parsed.
        # === Returns
        # true:: Always returns true.
        def environment(name, args)
          @environments ||= {}
          raise(ArgumentError, "Environment name must be a symbol") unless name.kind_of?(Symbol)
          @environments[name.to_sym] = Deployr::Environment.new(name, args, @config)
        end

        # Get the hash of current servers.
        #
        # === Returns
        # @deploy_options[:servers]<Hash>:: The current servers hash.
        def environments
          @environments ||= {}
          @environments
        end

        # Set the current servers hash
        #
        # === Parameters
        # val<Hash>:: The hash to set the servers to
        # === Returns
        # @deploy_options[:servers]<Hash>:: The current servers hash.
        def environments=(val)
          raise(ArgumentError, "Environments must recieve a hash") unless val.kind_of?(Hash)
          @environments = val
        end

      #end
    end
  end
end
