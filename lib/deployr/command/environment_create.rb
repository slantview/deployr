module Deployr
  class Command
    class EnvironmentCreate < Command
      
      banner "deployr environment create ENVIRONMENT (options)"
      
      def run
        
        @environment_name = @name_args[0]

        if @environment_name.nil?
          show_usage
          ui.fatal("You must specify an environment name")
          exit 1
        end

        ui.msg "Running Environment Create for (#{@environment_name})..."
      end
    end
  end
end