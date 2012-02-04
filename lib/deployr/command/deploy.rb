module Deployr
  class Command
    class Deploy < Command
      
      banner "deployr deploy (options)"

      option :environment,
        :short => "-E ENVIRONMENT",
        :long => "--dir DIR",
        :description => "The directory to initialize.",
        :default => ENV['HOME'] + "/.deployr"
      
      def run
        ui.msg "Running Deploy..."
      end
    end
  end
end