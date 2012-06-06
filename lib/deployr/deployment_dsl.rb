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
# Unless required by applicationlicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Deployr
  module DeploymentDSL

    # Add a Deployment definition to a Deployment
    #
    # === Parameters
    # name<Symbol>:: The name of the Deployment to add.
    # args<Hash>:: A hash of arguments specifying how it should be parsed.
    # === Returns
    # true:: Always returns true.
    def app(name, args)
      raise(ArgumentError, "Application name must be a symbol") unless name.kind_of?(Symbol)
      @application = Deployr::Application.new(name, args, @config)
    end

    # Add a auth key definition to a Deployment
    #
    # === Parameters
    # name<Symbol>:: The name of the key to add.
    # args<Hash>:: A hash of arguments specifying how it should be parsed.
    # === Returns
    # true:: Always returns true.
    def ssh_key(name, args)
      @ssh_keys ||= {}
      raise(ArgumentError, "ssh_key name must be a symbol") unless name.kind_of?(Symbol)
      @ssh_keys[name.to_sym] = Deployr::SshKey.new(name, args, @config)
    end

    def ssh_keys
      @ssh_keys ||= {}
      @ssh_keys
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
      @hooks[name.to_sym] = Deployr::Hook.new(name, args, @config)
    end

    # Get the hash of current hooks.
    #
    # === Returns
    # @deploy_options[:hooks]<Hash>:: The current hooks hash.
    def hooks
      @hooks ||= {}
      @hooks
    end

    # Set the current hooks hash
    #
    # === Parameters
    # val<Hash>:: The hash to set the hooks to
    # === Returns
    # @deploy_options[:hooks]<Hash>:: The current hooks hash.
    def hooks=(val)
      raise(ArgumentError, "hooks must recieve a hash") unless val.kind_of?(Hash)
      @hooks = val
    end

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
      @services[name.to_sym] = Deployr::Service.new(name, args)
    end

    # Get the hash of current services.
    #
    # === Returns
    # @deploy_options[:services]<Hash>:: The current services hash.
    def services
      @services ||= {}
      @services
    end

    # Set the current services hash
    #
    # === Parameters
    # val<Hash>:: The hash to set the services to
    # === Returns
    # @deploy_options[:services]<Hash>:: The current services hash.
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

  end
end
