

The script allows to run in sequence or parallel some scripts on remote hosts.

The list of servers can be choosen by pattern from aws account region or maestro region.

### Requirements:
* jq
* aws-cli (if aws cloud will be used)
* maestro-cli (if maestro cloud will be used)

### Usage
The script uses it's name to detect a region. Just create a soft link to
the real script and add a configuration file (see run.in.cfg.sample)
__Example__:

* The config file: _run.in.cfg.eu-west-1_
* The soft link: _run.in.eu-west-1.sh_

NB. All connect to remote hosts will be done _only_ with ssh key!!! 

### Options:
- without options returns the list of hosts from a region
- -g - regex pattern of host in the list
- -p - run in purallel
- -ss - make summary of execution results
- all other will be recognized as the script to run on remote hosts (if it is an exiting file the file will be copied and run)

### Misc:
- -s - show list to do ssh to chosen host
- see more in the script

### ToDo:
* use getopt
* process ansible inventory

# Examples
```
run.in.eu-west-1.sh -g oracle -p sh -c 'uname -a ; uptime'
```

### The End ;)
