module Deployr
  class Command
    class ServerList < Command
      
      banner "deployr server list (options)"
      
      def run
        ui.msg "Running Server List..."
      end
    end
  end
end