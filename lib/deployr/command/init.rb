module Deployr
  class Command
    class Init < Command
      
      banner "deployr init (options)"

      option :dir,
        :short => "-d DIR",
        :long => "--dir DIR",
        :description => "The directory to initialize.",
        :default => ENV['HOME'] + "/.deployr"
      
      def run
        ui.msg "Running Init..."
      end
    end
  end
end