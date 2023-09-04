module Configuration
  module Management
    module Framework
      class FileSystemHelper
        REMOTE_TRANSFER_PATH = "~/.cmf/transfers"
        DEFAULT_FILE_PERMISSION = '644'
        DEFAULT_DIRECTORY_PERMISSION = '755'

        ##
        # Creates an empty file on the remote host
        # It also can set permissions and ownership on the file.
        def self.create_file(path, name, **opts)
          create_path(path)
          file_path = "#{path}/#{name}"
          Framework.enqueue_cmd("touch #{file_path}")
          change_mode(file_path, opts[:permissions] || DEFAULT_FILE_PERMISSION)
          change_owner(file_path, opts[:ownership]) if opts[:ownership]
        end

        ##
        # Creates a directory or a path of nested directories on the remote host
        # It also can set permissions and ownership on the path.
        def self.create_path(path, **opts)
          Framework.enqueue_cmd("mkdir -p #{path}")
          change_owner(path, opts[:ownership]) if opts[:ownership]
          change_mode(path, opts[:permissions] || DEFAULT_DIRECTORY_PERMISSION)
        end

        ##
        # Changes ownership of the given file or path to the given owner and group
        def self.change_owner(path, ownership, *opts)
          Framework.enqueue_cmd("chown #{opts.join(" ")} #{ownership} #{path}")
        end

        ##
        # Changes permissions of the given file or path to the specified permissions
        def self.change_mode(path, perms, *opts)
          Framework.enqueue_cmd("chmod #{opts.join(" ")} #{perms} #{path}")
        end

        ##
        # TODO: FixMe
        # Updates content of a file on the remote host.
        # This method can be a little buggy depending on the passed text.
        def self.update_content(path, content, append = false)
          tee_opts = []
          tee_opts.append("-a") if append
          Framework.enqueue_cmd(["printf '%s' '#{content}' ","| ", "tee #{tee_opts.join(" ")} #{path}"])
        end

        ##
        # Copy a file or a path from local host to remote host.
        def self.copy_local_file(local, remote, **opts)
          file_name = File.basename(local)
          Framework.enqueue_ctrl_cmd("upload #{local}, #{REMOTE_TRANSFER_PATH}")
          Framework.enqueue_cmd("cp #{REMOTE_TRANSFER_PATH}/#{file_name} #{remote}")
          remote_file = "#{remote}/#{file_name}"
          change_mode(remote_file, opts[:permissions]) if opts[:permissions]
          change_owner(remote_file, opts[:ownership]) if opts[:ownership]
        end
      end
    end
  end
end
