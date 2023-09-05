require 'net/ssh'
require "net/scp"
require_relative '../errors/exceptions'

module Configuration
  module Management
    module Framework
      class CmfExec
        MAX_CHANNELS = 20
        attr_reader :output, :successes
        def initialize(**opts)
          @sudo = opts[:sudo]
          @output = {}
          @successes = []
          @logger = Logger.new(opts[:logfile] || $stdout)
          if opts[:verbose]
            @verbose = :debug
          end
          @dryrun = opts[:dryrun] || false
        end

        ##
        # Uploads a local file to the remote host
        def upload(ssh, host, local, remote)
          @logger.info("Uploading #{local} to #{remote} on #{host}")
          ssh.scp.upload!(local, remote)
        end

        ##
        # Establish an ssh connection and authenticate to the server
        # then execute the queued commands
        def ssh_cmd(host, **opts)
          @output[host] ||= []
          ssh_opts = { auth_methods: %w[publickey password],
                       non_interactive: true,
                       timeout: 10,
                       keys: Array(opts[:key]),
                       password: opts[:password],
                       port: opts[:port] || "22" }
          if @verbose
            ssh_opts[:verbose] = @verbose
            ssh_opts[:logger]  = @logger
          end
          user = opts[:user] || ENV['LOGNAME']
          
          if @dryrun
            get_cmds.each do |cmd|
              @logger.info("DRYRUN MODE: Running command: #{cmd} on host: #{host}")
            end
            return
          end

          Net::SSH.start(host.to_s, user, ssh_opts) do |ssh|
            process_ctrls(ssh, host)
            get_cmds.each do |cmd|
              @logger.info("Running command: #{cmd} on host: #{host}")
              ssh_exec(ssh, host, cmd)
            end
          end
          self
        rescue => e
          msg = "#{host}:#{e}"
          @logger.error(msg)
          output[host] << msg
        end

        private

        ##
        # Retrieves list of commands from the queue and inserts sudo if requested.
        def get_cmds
          cmds = Framework.get_cmd_queue
          cmds.map do |c|
            if c.kind_of?(Array)
              c.map do |cmd|
                if cmd.lstrip.start_with?('sudo', '|', '&&', ';')
                  cmd
                else
                  cmd.insert(0, 'sudo -S ')
                end
              end.join
            else
              if c.lstrip.start_with?('sudo')
                c
              else
                c.insert(0, 'sudo -S ')
              end
            end
          end
        end

        ##
        # Executes control comamnds which are translated into a ruby call in this class
        # This method currently only support the file upload.
        def process_ctrls(ssh, host)
          cmds = Framework.get_ctrl_queue
          cmds.each do |c|
            @logger.info("Running ctrl command: #{c} on host: #{host}")
            cmd = c.split(/[\s*(,)]/).reject {|e| e.to_s.empty?}
            method_name = cmd.shift
            if respond_to?(method_name)
              public_send(method_name, ssh, host, *cmd)
            else
              @logger.warn("Unknown control command #{c}, skipping!")
            end
          end
        end

        ##
        # TODO: Add support for unpriviledged users with password sudo
        # This method isn't currently in use.
        def ssh_data(data, channel, host)
          data = data.chomp
          pass_regexp = Regexp.union(/#{@user}@.*'s password:/,
                                     /#{@user}@([0-9]{0,3}\.){3}\.[0-9]{0,3}'s password:/,
                                     /password for #{@user}:/,
                                     /#{@user}'s password:/,
                                     /root's password:/)
          case data
          when pass_regexp
            channel.send_data("#{@ssh_pass.chomp}\n")
          when /^$/, %r{^Could not chdir to home directory /home/#{@user}}
            nil
          else
            data.each_line do |l|
              line = "#{host}: #{l.chomp}"
              output[host] << line.strip
            end
          end
          self
        end

        ##
        # This method populates command outputs to an array
        # where they will be sorted and printed at the end of the execution.
        def ssh_extended_data(stream, data, host)
          line = "<#{stream}>#{host}: #{data}"
          output[host] << line.strip
          self
        end

        ##
        # Executes a remote command over ssh connection
        def ssh_exec(chan, host, cmd)
          chan.exec!(cmd) do |_ch, stream, data|
            if !@successes.include?(host)
              @successes << host
            end
            ssh_extended_data(stream, data, host)
          end
        end

        ##
        # TODO: Add support for unpriviledged users with password sudo
        # This method isn't currently in use.
        def ssh_channel(channel, host, cmd)
          channel.request_pty do |chan, success|
            raise SshChannelError.new('Failed to open a pty') unless success
            ssh_exec(chan, host, cmd)
          end
        end
      end
    end
  end
end
