module Deployr
  class Command
    class ServerDelete < Command
      
      banner "deployr server delete SERVER (options)"
      
      def run
        ui.msg "Running Server Delete..."
      end
    end
  end
end