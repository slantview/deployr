module Deployr
  class CommandLoader
    
    DEPLOYR_FILE_IN_GEM = /deployr-[\d]+\.[\d]+\.[\d]+/
    CURRENT_DEPLOYR_GEM = /deployr-#{Regexp.escape(Deployr::VERSION)}/

    attr_reader :deployr_config_dir
    attr_reader :env
    
    def initialize(deployr_config_dir, env=ENV)
      Deployr::Log.debug "Initializing CommandLoader..."
      @deployr_config_dir, @env = deployr_config_dir, env
      @forced_activate = {}
    end
    
    def load_commands
      Deployr::Log.debug "Loading commands..."
      subcommand_files.each { |subcommand| Kernel.load subcommand }
      true
    end
    
    def subcommand_files
      @subcommand_files ||= (gem_and_builtin_subcommands.values + site_subcommands).flatten.uniq
    end
    
    # Returns an Array of paths to knife commands located in deployr_config_dir/command/
    # and ~/.deployr/command/
    def site_subcommands
      user_specific_files = []

      if deployr_config_dir
        user_specific_files.concat Dir.glob(File.expand_path("command/*.rb", deployr_config_dir))
      end

      # finally search ~/.deployr/command/*.rb
      user_specific_files.concat Dir.glob(File.join(env['HOME'], '.deployr', 'command', '*.rb'))

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