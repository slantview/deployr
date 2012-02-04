module Deployr
  class Command
    class EnvironmentList < Command

      deps do
        #require 'deployr/command/environment'
      end
      
      banner "deployr environment list (options)"

      option :environment,
        :short => "-E ENV",
        :long => "--env ENV",
        :description => "The environment to use.",
        :default => "production"
      
      def run
        ui.msg "Running Environment List..."
      end
    end
  end
end