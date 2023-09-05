module Configuration
  module Management
    module Framework
      class ValidRubyTask

        def initialize; end
        def hosts
          {
            'password': '-',
            '1.1.1.1': {
              'user': 'root'
            },
            '2.2.2.2': {
              'user': 'root'
            }
          }
        end
        def execute
          "abc"
        end
      end
    end
  end
end
