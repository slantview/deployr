module Deployr
  class Command
    class ServiceCreate < Command
      
      banner "deployr service create SERVICE (options)"
      
      def run
        ui.msg "Running Service Create..."
      end
    end
  end
end