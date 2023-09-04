module Configuration
  module Management
    module Framework
      class SystemdHelper
        ##
        # Restarts a service on the remote host.
        def self.restart_service(name)
          Framework.enqueue_cmd("systemctl restart #{name}")
        end

        ##
        # Enables a service on the remote host to start automatically on start up.
        def self.enable_service(name)
          Framework.enqueue_cmd("systemctl enable --now #{name}")
        end

        ##
        # Starts a service on the remote host.
        def self.start_service(name)
          Framework.enqueue_cmd("systemctl start #{name}")
        end

        ##
        # Stops a service on the remote host.
        def self.stop_service(name)
          Framework.enqueue_cmd("systemctl stop #{name}")
        end

        ##
        # Disables a service on the remote host so stop it from auto starting on start up.
        def self.disable_service(name)
          Framework.enqueue_cmd("systemctl disable --now #{name}")
        end
      end
    end
  end
end
