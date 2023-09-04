module Configuration
  module Management
    module Framework
      # The CmfRubyTask class, for executing tasks on hosts
      class CmfRubyTask
        def initialize(task_path)
          task_name = get_task_name(task_path)
          Framework.load_task(task_path)
          const = Framework.const_get(task_name)
          @task = const.new
        end

        ##
        # A helper method to get the task name from te provided path and filename
        # It's requirement that the class name of the task must be the CamelCase of the filename.
        def get_task_name(task_path)
          task_name = File.basename(task_path, ".*")
          task_name.split('_').map{|e| e.capitalize}.join
        end

        ##
        # An accessor method to the hosts defined in the provided task 
        def hosts
          @task.hosts
        end

        ##
        # Executes the defined commands in order to translate them into shell
        # commands and enqueue them for processing.
        def prepare_exec
          @task.execute
        end
      end
    end
  end
end
