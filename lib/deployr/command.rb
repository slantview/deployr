require 'deployr/command_loader'

module Deployr
  class Command
    
    def initialize(argv={})
      super() # having to call super in initialize is the most annoying anti-pattern :(
      #@ui = Deployr::UI.new(STDOUT, STDERR, STDIN, config)
      @ui = Deployr::UI.new(STDOUT, STDERR, STDIN)
      
      command_name_words = self.class.snake_case_name.split('_')

      # Mixlib::CLI ignores the embedded name_args
      @name_args = parse_options(argv)
      @name_args.delete(command_name_words.join('-'))
      @name_args.reject! { |name_arg| command_name_words.delete(name_arg) }

      # deployr node run_list add requires that we have extra logic to handle
      # the case that command name words could be joined by an underscore :/
      command_name_words = command_name_words.join('_')
      @name_args.reject! { |name_arg| command_name_words == name_arg }

      # if config[:help]
      #   msg opt_parser
      #   exit 1
      # end
    end
    
    def self.run(args, options={})
      Deployr::Log.debug "Running..."
      load_commands
      command_class = command_class_from(args)
      command_class.options = options.merge!(command_class.options)
      command_class.load_deps unless want_help?(args)
      instance = command_class.new(args)
      instance.configure_deployr
      #instance.run_with_pretty_exceptions
    end
    
    def self.command_class_from(args)
      command_words = args.select {|arg| arg =~ /^(([[:alnum:]])[[:alnum:]\_\-]+)$/ }

      command_class = nil

      while ( !command_class ) && ( !command_words.empty? )
        snake_case_class_name = command_words.join("_")
        unless command_class = commands[snake_case_class_name]
          command_words.pop
        end
      end
      # see if we got the command as e.g., deployr node-list
      command_class ||= commands[args.first.gsub('-', '_')]
      command_class || command_not_found!(args)
    end
    
    def self.snake_case_name
      convert_to_snake_case(name.split('::').last) unless unnamed?
    end
    
    # Load all the sub-commands
    def self.load_commands
       @commands_loaded ||= command_loader.load_commands
      true
    end
    
    def self.command_loader
      begin
        @command_loader || Deployr::CommandLoader.new(deployr_config_dir)
      rescue
        #TODO: Fix this. #hardcoded
        @deployr_config_dir = '/Users/steverude/.deployr'
        @command_loader || Deployr::CommandLoader.new(@deployr_config_dir)
      end
    end
    
    @@deployr_config_dir = nil

    # search upward from current_dir until .deployr directory is found
    def self.deployr_config_dir
      if @@deployr_config_dir.nil? # share this with subclasses
        @@deployr_config_dir = false
        full_path = Dir.pwd.split(File::SEPARATOR)
        (full_path.length - 1).downto(0) do |i|
          candidate_directory = File.join(full_path[0..i] + [".deployr" ])
          if File.exist?(candidate_directory) && File.directory?(candidate_directory)
            @@deployr_config_dir = candidate_directory
            break
          end
        end
      end
      @@deployr_config_dir
    end
    
    def self.list_commands(preferred_category=nil)
      load_commands

      category_desc = preferred_category ? preferred_category + " " : ''
      Deployr::UI.msg "Available #{category_desc}commands: (for details, deployr SUB-COMMAND --help)\n\n"
      
      if preferred_category && commands_by_category.key?(preferred_category)
        commands_to_show = {preferred_category => commands_by_category[preferred_category]}
      else
        commands_to_show = commands_by_category
      end
      
      commands_to_show.sort.each do |category, commands|
        next if category =~ /deprecated/i
        Deployr::UI.msg "--- #{category.upcase} COMMANDS ---"
        commands.each do |command|
          Deployr::UI.msg commands[command].banner if commands[command]
        end
        Deployr::UI.msg
      end
    end
    
    def self.want_help?(args)
      (args.any? { |arg| arg =~ /^(:?(:?\-\-)?help|\-h)$/})
    end
    
    def configure_deployr
      unless config[:config_file]
        if self.class.deployr_config_dir
          candidate_config = File.expand_path('deployr.rb',self.class.deployr_config_dir)
          config[:config_file] = candidate_config if File.exist?(candidate_config)
        end
        # If we haven't set a config yet and $HOME is set, and the home
        # deployr.rb exists, use it:
        if (!config[:config_file]) && ENV['HOME'] && File.exist?(File.join(ENV['HOME'], '.deployr', 'deployr.rb'))
          config[:config_file] = File.join(ENV['HOME'], '.deployr', 'deployr.rb')
        end
      end

      # Don't try to load a deployr.rb if it doesn't exist.
      if config[:config_file]
        read_config_file(config[:config_file])
      else
        # ...but do log a message if no config was found.
        Deployr::Config[:color] = config[:color]
        ui.warn("No deployr configuration file found")
      end

      Deployr::Config[:color] = config[:color]

      case config[:verbosity]
      when 0
        Deployr::Config[:log_level] = :error
      when 1
        Deployr::Config[:log_level] = :info
      else
        Deployr::Config[:log_level] = :debug
      end

      Deployr::Config[:node_name]         = config[:node_name]       if config[:node_name]
      Deployr::Config[:client_key]        = config[:client_key]      if config[:client_key]
      Deployr::Config[:deployr_server_url]   = config[:deployr_server_url] if config[:deployr_server_url]
      Deployr::Config[:environment]       = config[:environment]     if config[:environment]

      # Expand a relative path from the config directory. Config from command
      # line should already be expanded, and absolute paths will be unchanged.
      if Deployr::Config[:client_key] && config[:config_file]
        Deployr::Config[:client_key] = File.expand_path(Deployr::Config[:client_key], File.dirname(config[:config_file]))
      end

      Mixlib::Log::Formatter.show_time = false
      Deployr::Log.init(Deployr::Config[:log_location])
      Deployr::Log.level(Deployr::Config[:log_level] || :error)

      Deployr::Log.debug("Using configuration from #{config[:config_file]}")

      if Deployr::Config[:node_name].nil?
        #raise ArgumentError, "No user specified, pass via -u or specifiy 'node_name' in #{config[:config_file] ? config[:config_file] : "~/.deployr/deployr.rb"}"
      end
    end
    
  end
end