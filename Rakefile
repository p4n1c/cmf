require 'rspec/core/rake_task'
# require 'rubocop/rake_task'

# Ruby code style checking/enforcement via Rubocop
#RuboCop::RakeTask.new(:rubocop) do |task|
#  task.patterns = %w[ bin lib spec]
#  task.formatters = %w[fuubar html]
#  task.options += [
#    '--display-style-guide',
#    '--display-cop-names',
#    '--extra-details',
#    '--out', File.join('docs', 'rubocop.html')
#  ]
#  task.fail_on_error = true
#end
# task :release => :rubocop

desc 'Run our unit tests in spec/ with coverage'
RSpec::Core::RakeTask.new(:spec) do |task|
  task.exclude_pattern = "spec/acceptance/**"
end
task release: :spec
