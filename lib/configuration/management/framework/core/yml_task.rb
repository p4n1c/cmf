require 'yaml'
require_relative '../errors/exceptions'
require_relative '../helpers/file_system'

module Configuration
  module Management
    module Framework
      # The CmfYamlTask class, for executing tasks on hosts
      class CmfYamlTask
        def initialize(task_path)
          @task = YAML.load(File.read(task_path))
          p @task
        end

        ##
        # An accessor method to the hosts defined in the provided task 
        def hosts
          raise InvalidRubyTaskError.new('YamlTasks must include `hosts` map') if @task[:hosts].nil?
          @task[:hosts]
        end

        ##
        # Executes the defined commands in order to translate them into shell
        # commands and enqueue them for processing.
        def prepare_exec
          raise InvalidRubyTaskError.new('YamlTasks must include `commands` array') if @task[:commands].nil?
          process_files_and_ctrls
          @task[:commands].each {|c| Framework.enqueue_cmd(c) }
        end

        def process_files_and_ctrls
          return if @task[:files].nil?
          upload = Array(@task[:files]["upload"])
          upload.each {|u| FileSystemHelper.copy_local_file(u["src"], u["dst"])}
          update = Array(@task[:files]["update"])
          p update
          update.each {|u| FileSystemHelper.update_content(u["file"], u["content"]) }
        end
      end
    end
  end
end
