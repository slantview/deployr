module Deployr
  class Command
    class EnvironmentDelete < Command
      
      banner "deployr environment delete ENVIRONMENT (options)"
      
      def run
        @environment_name = @name_args[0]

        if @environment_name.nil?
          show_usage
          ui.fatal("You must specify an environment name")
          exit 1
        end

        ui.msg "Running Environment Delete for (#{@environment_name})..."
      end
    end
  end
end