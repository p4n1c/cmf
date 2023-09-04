module Configuration
  module Management
    module Framework
      class AptHelper
        ##
        # Installs packages using apt command available on ubuntu and debian linux.
        def self.install_packages(*pkgs)
          self.update
          Framework.enqueue_cmd("apt -y -qq install #{pkgs.join(' ')}")
        end

        ##
        # Removes packages using apt command available on ubuntu and debian linux.
        def self.remove_packages(*pkgs)
          Framework.enqueue_cmd("apt -y -qq remove #{pkgs.join(' ')}")
        end

        ##
        # Upgrades packages using apt command available on ubuntu and debian linux.
        def self.upgrade
          self.update
          Framework.enqueue_cmd("apt -y -qq upgrade")
        end

        ##
        # Updates package cache from remote repository using apt command available on ubuntu and debian linux.
        def self.update
          Framework.enqueue_cmd("apt -qq update")
        end
      end
    end
  end
end
