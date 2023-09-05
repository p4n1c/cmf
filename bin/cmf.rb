#!/usr/bin/env ruby

require_relative '../lib/init'
require 'json'
require 'highline'
require 'optparse'

def bail(msg, optparse, code = 9)
  warn msg
  warn optparse
  exit code
end

options = { sudo: false,
            dryrun: false,
            hosts: {},
            verbose: false}
help = false
optparse = OptionParser.new do |opts|
  opts.banner = "Usage: #{$PROGRAM_NAME} <options>"
  opts.separator ''
  opts.separator '  Options:'
  opts.on('-v', '--verbose', 'Verbose logging to /tmp/cmf-PID.log') { options[:verbose] = true }
  opts.on('-d', '--dryrun', 'Run in dryrun mode', FalseClass) { |_| options[:dryrun] = true }
  opts.on('-t',
          '--threaded [THREADS]',
          'Run concurrently in THREADS amount of threads instead of serial (Default: unlimited)',
          Integer) { |t| options[:threaded] = t || 0 }
  opts.on('-e',
          '--exec COMMAND',
          'Remote command to execute on the servers',
          String) { |e| options[:cmd] = e }
  opts.on('-H',
          '--host HOSTS_FILE',
          'Path to json file where hosts, users and auth method are defined',
          String) { |h| options[:hosts] = JSON.parse(File.read(h))}
  opts.on('-s',
          '--sudo',
          'Execute tasks with sudo access',
          FalseClass) { |_| options[:sudo] = true }
  opts.on('-r',
          '--ruby TASK_RUBY_FILE',
          'Path to ruby task file to execute',
          String) { |r| options[:rb_task] = r }
  opts.on('-y',
          '--yaml TASK_YAML_FILE',
          'Path to yaml task file to execute',
          String) { |y| options[:yml_task] = y }
  opts.on('-h', '--help', 'This help', FalseClass) { |_| help = true }
  opts.separator '  Examples:'
  opts.separator "    #{$PROGRAM_NAME} -r path/to/task.rb"
  opts.separator "    #{$PROGRAM_NAME} -y path/to/task.yml"
  opts.separator "    #{$PROGRAM_NAME} -s -e 'whoami' -H hosts.json"
  opts.separator "    #{$PROGRAM_NAME} -s -d -r path/to/task.rb"
end

# Parse arguments
optparse.parse!(ARGV)

# Show help if it was requested
if help
  puts optparse
  exit 0
end

if options[:verbose]
  options[:logfile] = "/tmp/cmf-#{$$}log" # rubocop:disable Style/SpecialGlobalVars
  warn("Logging ssh debug info to #{options[:logfile]}")
end

unless options[:rb_task] || options[:yml_task] || options[:cmd]
  bail('Ruby task, yaml task or a command must be provided', optparse)
end

cmf = Configuration::Management::Framework::Cmf.execute_display(**options)

warn "Success on #{cmf.successes}"
warn "Failures on #{cmf.fails}" if cmf.fails.count > 0
