#!/bin/bash

MY_NAME=${0##./}

####################
# helper functions
####################
function good() {
  TEXT=$@
  echo -e [$MY_NAME] $'\e[32m'$TEXT$'\e[00m'
}
function warn() {
  TEXT=$@
  echo -e $'\e[41m'[$MY_NAME] $TEXT$'\e[00m'
}
function die() {
  warn $@
  exit 1
}
function success(){
  TEXT=$@
  echo -e $'\e[30;42m'[$MY_NAME] $TEXT$'\e[00m'
}
function run() {
  CMD=$@
  $CMD
  RET_VAL=$?
  if [[ $RET_VAL -gt 0 ]]; then
    warn ">$CMD< exited unclean"
    exit $RET_VAL
  fi
}
function vagrant_up_provision() {
  VM=$1
  vagrant status | grep $1 | grep running > /dev/null
  if [[ $? -eq 0 ]]; then
    good VM $VM already running. Doing a provisioning.
    run vagrant provision $VM
  else
    good Spinning new VM $VM up
    run vagrant up $VM
  fi
}
function cmd_exists(){
  type "$1" &> /dev/null ;
}

####################
# ENV check: vagrant
####################
if ! cmd_exists "vagrant"; then
  die Vagrant executable not found. Install it from http://www.vagrantup.com
fi

####################
# Vagrant plugins
####################
for plugin in hostmanager omnibus; do
  vagrant plugin list | grep vagrant-$plugin > /dev/null
  if [[ $? -eq 0 ]]; then
    good Vagrant plugin $plugin already installed
  else
    vagrant plugin install vagrant-$plugin
  fi
done

###################
# Ruby
###################

if ! cmd_exists ruby; then
 die Ruby is not installed
fi

if ! cmd_exists gem; then
 die "Ruby Gems is not installed. Install it! (maybe: apt-get install rubygems)"
fi


####################
# Knife setup
####################

if ! cmd_exists knife; then
  good Installing the chef gem
  gem install chef --no-rdoc --no-ri
fi

if [[ ! -d .chef/ ]]; then
  good Creating .chef/
  mkdir .chef
fi

if [[ ! -f .chef/knife.rb ]]; then
  good Copying knife.rb.example to .chef/knife.rb
  cp knife.rb.example .chef/knife.rb
fi


####################
# Chef Server
####################
good Setting up the Chef-Server
vagrant_up_provision chef-server

if [[ ! -f .chef/admin.pem ]]; then
  die .chef/admin.pem does not exist, feels like the provisioning failed
fi

good Chef server is up and running
good admin.pem and chef-validator.pem have been copied to .chef/

####################
# Chef upload
####################
good Uploading cookbooks
run find cookbooks -type d -depth 1  | sed -e "s/cookbooks\///g" | xargs knife cookbook upload
good Uploading roles
run knife role from file roles/*.rb
good Uploading environments
run knife environment from file environments/*.rb

####################
# Node allinone
####################
good Spinning up the allinone none
vagrant up allinone

good Reloading the allinone node, as we need one restart to make things work
vagrant reload allinone

####################
# Other nodes
####################
good "Spinning up the remaining nodes (if any)"
run vagrant up

####################
# Success
####################
success We\'re done!
success You can now log into OpenStack Horizon at https://allinone.openstack.vagrant with admin / secrete.

####################
# Open Horizon
####################
OPEN_PATH=$(which open)
if [[ -x "$OPEN_PATH" ]]; then
  $OPEN_PATH https://allinone.openstack.vagrant/
fi
