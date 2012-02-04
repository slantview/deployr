require 'deployr/command'

module Deployr
  class CLI
    module Execute
      # Execute the command
      def execute
        Mixlib::Log::Formatter.show_time = false
        validate_and_parse_options
        quiet_traps
        execute!
        exit 0
      end
      
      # Internal execute command
      def execute!
        Deployr::Command.run(ARGV, options)
      end
      
      private
      def quiet_traps
        trap("TERM") do
          exit 1
        end
        
        trap("INT") do
          exit 2
        end
      end
      
    end
  end
end