require_relative 'cmf/rb_task'
require_relative 'cmf/cmf_exec'

module Configuration
  module Management
    module Framework
      # The Cmf class, for executing tasks or a command on many hosts
      class Cmf
        # entry point and main function
        def self.execute_display(**opts)
          cmf = new(**opts)
          cmf.prepare_exec
          cmf.hosts_exec
          output = cmf.output
          output.keys.sort_by(&:to_s).each do |key|
            output[key].each do |line|
              puts line
            end
          end
          cmf
        end

        attr_reader :hosts
        def initialize(**opts)
          @threaded = opts[:threaded]
          @sudo = opts[:sudo]
          @threads = []
          @cmd = opts[:cmd]
          @rb_task = CmfRubyTask.new(opts[:rb_task]) if opts[:rb_task]
          @yml_task = CmfYamlTask.new(opts[:yml_task]) if opts[:yml_task]
          @hosts = fetch_hosts_from_tasks
          @hosts.merge!(opts[:hosts]) unless opts[:hosts].empty?
          @hosts = @hosts.deep_symbolize_keys
          populate_hosts_passwords
          require 'thread' if @threaded
          @cmf_exec = CmfExec.new(**opts)
        end

        ##
        # hosts can be defined in a json file and passed throw cli
        # or can also be defined inside every task separately
        def fetch_hosts_from_tasks
          hosts = {}
          hosts.merge!(@rb_task.hosts) if @rb_task
          hosts.merge!(@yml_task.hosts) if @yml_task
          hosts
        end

        ##
        # We don't allow passwords to be hardcoded into the tasks
        # instead of prompt the user to enter the password secretly
        def populate_hosts_passwords
          password = ask_for_password if @hosts[:password].eql?('-')
          key = @hosts[:key]
          @hosts = @hosts.map do |host, opts|
            next if opts.kind_of?(String)
            if password.nil? && key.nil? && opts[:key].nil? && opts[:password].nil?
              abort 'key or password field is required'
            end
            opts[:key] ||= key
            unless opts[:password].nil?
              if opts[:password].eql?('-')
                opts[:password] = ask_for_password(host)
              else
                abort 'for security reasons, password field can only be set to -'
              end
            end
            opts[:password] ||= password
            [host, opts]
          end.compact.to_h
        end

        def ask_for_password(host = 'all hosts')
          cli = HighLine.new($stdin, $stderr)
          cli.ask("SSH Password for #{host}: ", nil) { |r| r.echo = '***'; }
        end

        ##
        # methods or calls defined in the tasks are translated into bash commands
        # and pushed into a queue that gets processed after the ssh connection has been established.
        def prepare_exec
          @rb_task.prepare_exec if @rb_task
          @yml_task.prepare_exec if @yml_task
          Framework.enqueue_cmd(@cmd) if @cmd
        end

        ##
        # This accessor methhod returns output of the task or command execution.
        def output
          @cmf_exec.output
        end

        ##
        # This accessor method returns the list of hosts that has been updated successfully.
        def successes
          @cmf_exec.successes
        end

        ##
        # This method returns the list of hsots that failed to update.
        def fails
          @fails ||= hosts.keys - successes
        end

        ##
        # Cleans threads that were used to parallalize the processign on different hosts.
        def clean_threads
          until @threads.empty?
            @threads.each do |t|
              unless t.alive?
                t.join
                @threads.delete t
              end
            end
          end
        end

        ##
        # Executes the task on a host in a separate thread.
        def thread_exec(host, **opts)
          @threads << Thread.new { @cmf_exec.ssh_cmd(host, **opts) }
          return if @threaded.zero?
          clean_threads if (@threads.size % @threaded).zero?
        end

        ##
        # Executes the task on the provided list of hosts.
        def hosts_exec
          abort("No hosts were given") if @hosts.empty? 
          @hosts.each do |host, opts|
            if @threaded
              thread_exec(host, **opts)
            else
              @cmf_exec.ssh_cmd(host, **opts)
            end
          end
          clean_threads if @threaded
          self
        end
      end
    end
  end
end
