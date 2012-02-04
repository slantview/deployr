module Deployr
  class Command
    class Rollback < Command
      
      banner "deployr rollback (options)"

      option :dir,
        :short => "-d DIR",
        :long => "--dir DIR",
        :description => "The directory to initialize.",
        :default => ENV['HOME'] + "/.deployr"
      
      def run
        ui.msg "Running Rollback..."
      end
    end
  end
end