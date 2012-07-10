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
  class Deployment
    module Runner

      attr_accessor :errors
      attr_accessor :transaction
      attr_accessor :command

      def start(command)
        @command = command
        @hooks.each do |hook, options|
          if (options[:command] == @command.command_name.to_sym)
            begin
              transaction do 
                @command.send(options[:callback])
              end
            rescue Exception => e
              #@errors.push(e)
              @command.send(:rollback, "#{e}")
              exit -1
            end
          end
        end

        finish
      end

      def transaction(&block)
        @transaction = Hash.new
        @errors = Array.new
        block.call
      end

      def finish
        # if no errors, finalize transaction
        @command.finish
      end
    end
  end
end
