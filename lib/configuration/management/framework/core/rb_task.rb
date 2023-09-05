require_relative '../errors/exceptions'

module Configuration
  module Management
    module Framework
      # The CmfRubyTask class, for executing tasks on hosts
      class CmfRubyTask
        def initialize(task_path)
          Framework.load_task(task_path)
          task_klass = get_task_name(task_path)
          @task = task_klass.new
        end

        ##
        # A helper method to get the task name from te provided path and filename
        # It's requirement that the class name of the task must be the CamelCase of the filename.
        def get_task_name(task_path)
          task_name = File.basename(task_path, ".*")
          Framework.const_get(task_name.split('_').map{|e| e.capitalize}.join)
        rescue NameError => _e
          raise InvalidRubyTaskError.new('RubyTasks must:
                                             -  Be implemented under Configuration::Management::Framework
                                             -  Have a CamelCase class name of the task file name')
        end

        ##
        # An accessor method to the hosts defined in the provided task 
        def hosts
          raise InvalidRubyTaskError.new('RubyTasks must implement `hosts` accessor method') unless @task.respond_to?(:hosts)
          @task.hosts
        end

        ##
        # Executes the defined commands in order to translate them into shell
        # commands and enqueue them for processing.
        def prepare_exec
          raise InvalidRubyTaskError.new('RubyTasks must implement `execute` method') unless @task.respond_to?(:execute)
          @task.execute
        end
      end
    end
  end
end
