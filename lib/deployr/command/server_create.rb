module Deployr
  class Command
    class ServerCreate < Command
      
      banner "deployr server create SERVER (options)"
      
      def run
        ui.msg "Running Server Create..."
      end
    end
  end
end