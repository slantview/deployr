module Deployr
  class Command
    class EnvironmentEdit < Command
      
      banner "deployr environment edit ENVIRONMENT (options)"

      option :environment,
        :short => "-E ENVIRONMENT",
        :long => "--environment ENVIRONMENT",
        :description => "The environment to use.",
        :default => "production"
      
      def run
        ui.msg "Running Environment Edit..."
      end
    end
  end
end