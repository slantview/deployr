module Deployr
  class Command
    class ApplicationList < Command
      
      banner "deployr application list (options)"
      
      def run
        ui.msg "Running Application List..."
      end
    end
  end
end