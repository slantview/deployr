module Deployr
  class Command
    class ServiceDelete < Command
      
      banner "deployr service delete SERVICE (options)"
      
      def run
        ui.msg "Running Service Delete..."
      end
    end
  end
end