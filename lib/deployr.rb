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

require 'deployr/version'
require 'deployr/config'
require 'deployr/log'
require 'deployr/ui'
require 'deployr/command'
#require 'deployr/db'

module Deployr
  DEPLOYR_ROOT = File.dirname(File.expand_path(File.dirname(__FILE__)))

  Error = Class.new(RuntimeError)

  CaptureError            = Class.new(Deployr::Error)
  NoSuchTaskError         = Class.new(Deployr::Error)
  NoMatchingServersError  = Class.new(Deployr::Error)

  class RemoteError < Error
    attr_accessor :hosts
  end

  ConnectionError     = Class.new(Deployr::RemoteError)
  TransferError       = Class.new(Deployr::RemoteError)
  CommandError        = Class.new(Deployr::RemoteError)
  FatalError          = Class.new(Deployr::RemoteError)

  LocalArgumentError  = Class.new(Deployr::Error)
end
