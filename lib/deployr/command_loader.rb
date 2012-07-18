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
  class CommandLoader
    
    DEPLOYR_FILE_IN_GEM = /deployr-[\d]+\.[\d]+\.[\d]+/
    CURRENT_DEPLOYR_GEM = /deployr-#{Regexp.escape(Deployr::VERSION)}/

    attr_reader :deployr_config_dir
    attr_reader :env
    
    def initialize(deployr_config_dir, env=ENV)
      @deployr_config_dir, @env = deployr_config_dir, env
      @forced_activate = {}
    end
    
    def load_commands
      subcommand_files.each { |subcommand| Kernel.load subcommand }
      true
    end
    
    def subcommand_files
      @subcommand_files ||= (gem_and_builtin_subcommands.values + site_subcommands).flatten.uniq
    end
    
    # Returns an Array of paths to deployr commands located in deployr_config_dir/command/
    # and ~/.deployr/command/
    def site_subcommands
      user_specific_files = []

      if deployr_config_dir
        user_specific_files.concat Dir.glob(File.expand_path("command/*.rb", deployr_config_dir))
      end

      # Search ~/.deployr/command/*.rb
      user_specific_files.concat Dir.glob(File.join(env['HOME'], '.deployr', 'command', '*.rb'))
      
      # Search PWD/command/*.rb
      user_specific_files.concat Dir.glob(File.join(Dir.getwd, 'command', '*.rb'))

      user_specific_files
    end
    
    def gem_and_builtin_subcommands
      # search all gems for deployr/command/*.rb
      require 'rubygems'
      find_subcommands_via_rubygems
    rescue LoadError
      find_subcommands_via_dirglob
    end

    def find_subcommands_via_rubygems
      files = Gem.find_files 'deployr/command/*.rb'
      files.reject! {|f| from_old_gem?(f) }
      subcommand_files = {}
      files.each do |file|
        rel_path = file[/(#{Regexp.escape File.join('deployr', 'command', '')}.*)\.rb/, 1]
        subcommand_files[rel_path] = file
      end

      subcommand_files.merge(find_subcommands_via_dirglob)
    end
    
    def find_subcommands_via_dirglob
      files = Dir[File.expand_path('../command/*.rb', __FILE__)]
      subcommand_files = {}
      files.each do |recipe|
        rel_path = recipe[/#{Deployr::DEPLOYR_ROOT}#{Regexp.escape(File::SEPARATOR)}(.*)\.rb/,1]
        subcommand_files[rel_path] = recipe
      end
      subcommand_files
    end

    # wow, this is a sad hack :(
    # Gem.find_files finds files in all versions of a gem, which
    # means that if multiple versions are installed, we'll try to
    # require, e.g., which will cause a gem activation error. So 
    # remove files from older gems.
    def from_old_gem?(path)
      path =~ DEPLOYR_FILE_IN_GEM && path !~ CURRENT_DEPLOYR_GEM
    end
    
  end
end