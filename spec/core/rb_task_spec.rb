require_relative '../../lib/init'
require_relative '../../lib/configuration/management/framework/core/rb_task'
require_relative '../../lib/configuration/management/framework/errors/exceptions'

module Configuration
  module Management
    module Framework
      RSpec.describe CmfRubyTask do

        let(:valid_host_map) { {'password': '-', '1.1.1.1': {'user': 'root'}, '2.2.2.2': {'user': 'root'}} }

        it 'should throw when no hosts method is defined' do
          task = CmfRubyTask.new('spec/resources/no_hosts_ruby_task.rb')
          expect { task.hosts }.to raise_error(InvalidRubyTaskError)
        end
        
        it 'should throw when no execute method is defined' do
          task = CmfRubyTask.new('spec/resources/no_execute_ruby_task.rb')
          expect { task.prepare_exec }.to raise_error(InvalidRubyTaskError)
        end

        it 'should throw when class name mismatches' do
          expect { CmfRubyTask.new('spec/resources/mismatched_ruby_task_name.rb') }.to raise_error(InvalidRubyTaskError)
        end

        it 'should work with valid ruby task' do
          task = CmfRubyTask.new('spec/resources/valid_ruby_task.rb')
          expect(task.hosts).to eq(valid_host_map)
          expect(task.prepare_exec).to eq('abc')
        end
      end
    end
  end
end
