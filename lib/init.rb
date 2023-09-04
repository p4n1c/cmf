require 'pathname'
require_relative 'configuration/management/framework/cmf'

# Path name class
class Pathname
  def /(other)
    join(other.to_s)
  end
end

class Hash
  def deep_symbolize_keys
    self.each_with_object({}) { |(k, v), h| h[k.to_sym] = v.is_a?(Hash) ? v.deep_symbolize_keys : v }
  end
end

module Configuration
  module Management
    module Framework
      LIBROOT =  Pathname(__FILE__).dirname.expand_path
      ROOT = LIBROOT / '..'
      SPEC_HELPER_PATH = ROOT / :spec
      def self.load_task(file)
        require(ROOT.join(file).to_s)
      end

      def self.enqueue_cmd(cmd)
        @cmd_queue ||= []
        @cmd_queue.append(cmd)
      end

      def self.get_cmd_queue
        @cmd_queue || []
      end

      def self.enqueue_ctrl_cmd(cmd)
        @ctrl_queue ||=[]
        @ctrl_queue.append(cmd)
      end

      def self.get_ctrl_queue
        @ctrl_queue || []
      end
    end
  end
end
