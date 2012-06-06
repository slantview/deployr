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

require 'deployr/ssh'

module Deployr
  class Server
    include Comparable

    attr_accessor :name
    attr_accessor :options
    attr_reader :host
    attr_reader :port
    attr_reader :user
    attr_reader :key

    def self.default_user
      ENV['USER'] || ENV['USERNAME'] || "deployr"
    end

    def self.default_key
      "~/.ssh/id_rsa.pub"
    end

    def initialize(name, options = {}, config = {})
      @name, @options, @config = name, options, config

      @host = @options[:ip_address]
      @port = @options[:port] || 22
      @user = @options[:ssh_user] || default_user
      @key = @options[:ssh_key] || default_key

    end

    def connect
      @connection = Deployr::SSH.connect(self, @options)
      @connected = true
    end

    def connection
      @connection
    end

    def exec(cmd)
      @connection.exec!(cmd)
    end

    def <=>(server)
      [host, port, user] <=> [server.host, server.port, server.user]
    end

    # Redefined, so that Array#uniq will work to remove duplicate server
    # definitions, based solely on their host names.
    def eql?(server)
      host == server.host &&
        user == server.user &&
        port == server.port
    end

    alias :== :eql?

    # Redefined, so that Array#uniq will work to remove duplicate server
    # definitions, based on their connection information.
    def hash
      @hash ||= [host, user, port].hash
    end

    def to_s
      @to_s ||= begin
        s = host
        s = "#{user}@#{s}" if user
        s = "#{s}:#{port}" if port && port != 22
        s
      end
    end
  end
end
