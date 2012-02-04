module Deployr
  class Command
    class ServiceList < Command
      
      banner "deployr service list (options)"
      
      def run
        ui.msg "Running Service List..."
      end
    end
  end
end