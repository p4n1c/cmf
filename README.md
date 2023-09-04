# Welcome to CMF!
## Overview
CMF is an project assignment :)
It's a framework that allows running certain code defined tasks, and or yaml defined tasks (yaml support is not implemneted).
Tasks can be defined as ruby class with a few helper methods provided to support basic tasks that could be needed to setup a server.
It's highly extensible that it allows the user to extend the functionality even within the defined tasks itself.

## Usage Requirements
In order to create a new task in ruby, you must adhere the following requirement in your task:
- Your task file must live in the tasks folder under the project root.
- Your task's class must be part of the Configuration::Management::Framework module chain
- Your task's class name must be the CamelCase of your task filename (ie: if your task filename is my_task.rb, then your class name must be MyTask)
- Your task must implement a method which returns the defined hosts as a hash under the following schema:
```
{
        "host1": {
                "user": "user1",
                "key": "/path/to/key.pem"
        },
        "host2": {
                "user": "ubuntu",
                "password": "-"
        },
        "password": "-",
        "key": "/path/to/key.pem"
}
```
- - User must be root, or a NOPASSWORD sudoer at the moment.
- - a Key or a Password field must be specified.
- - Password field can only be set to "-" which means prompt for password.
- - You can also define a global password field or key if the defined servers have the same password or key.

## Setup
- Unpack the zip file and cd to the project directory.
- Install bundler by running ```gem install bundler``` (install ruby and gem using your package manager if you don't have them installed).
- Within the project directory run ```bundle install``` in order to install the dependencies
- Run ./bin/cmf.rb! Happy CMF'ing!

## Cli & Example runs
```
Usage: ./bin/cmf.rb <options>

  Options:
    -v, --verbose                    Verbose logging to /tmp/cmf-PID.log
    -t, --threaded [THREADS]         Run concurrently in THREADS amount of threads instead of serial (Default: unlimited)
    -e, --exec COMMAND               Remote command to execute on the servers
    -H, --host HOSTS_FILE            Path to json file where hosts, users and auth method are defined
    -s, --sudo                       Provide Sudo password
    -r, --ruby TASK_RUBY_FILE        Path to ruby task file to execute
    -y, --yaml TASK_YAML_FILE        Path to yaml task file to execute
    -h, --help                       This help
  Examples:
    ./bin/cmf.rb -s -r path/to/task.rb
    ./bin/cmf.rb -y path/to/task.yml
    ./bin/cmf.rb -s -e 'whoami' -H hosts.json
```
