#!/bin/bash


function good() {
  TEXT=$@
  echo -e $'\e[32m'$TEXT$'\e[00m'
}
function die() {
  TEXT=$@
  echo -e $'\e[41m'$TEXT$'\e[00m'
  exit 1
}

VAGRANT_PATH=$(which vagrant)
if [[ -x "$VAGRANT_PATH" ]]; then
  good Vagrant found at $VAGRANT_PATH
else
  die Vagrant executable not found. Install it from http://www.vagrantup.com
fi

for plugin in hostmanager omnibus; do
  vagrant plugin install vagrant-$plugin
done

good Setting up the Chef-Server

vagrant up chef-server

good Chef server is up and running
good Take the files admin.pem and validation.pem and copy them to .chef/

die Sorry, the rest is not implemented! Upload roles, cookbooks and environments to https://chef-server.openstack.vagrant and then run `vagrant up allinone`.

# prompt Did you copy them?

# knife upload . -c .chef/knife-vagrant.rb
# knife role from file environments/*.rb -c .chef/knife-vagrant.rb
# knife environment from file environments/*.rb -c .chef/knife-vagrant.rb

