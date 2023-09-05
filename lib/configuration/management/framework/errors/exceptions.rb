class InvalidRubyTaskError < StandardError
  def initialize(msg='Not a valid ruby task')
    super
  end
end

class InvalidYamlTaskError < StandardError
  def initialize(msg='Not a valid yaml task')
    super
  end
end

class InvalidHostDefinitionError < StandardError
  def initialize(msg='Not a valid host definition')
    super
  end
end

class SshChannelError < StandardError
  def initialize(msg='SSH Channel Error')
    super
  end
end
