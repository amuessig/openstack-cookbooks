name "vagrant"
description "Defines the network and database settings you're going to use with OpenStack. The networks will be used in the libraries provided by the osops-utils cookbook. This example is for FlatDHCP with 2 physical networks."

override_attributes(
  "package_component" => "grizzly",
  "glance" => {
    "image_upload" => true,
    "images" => ["precise"],
    "image" => {
      # "precise" => "https://cloud-images.ubuntu.com/precise/current/precise-server-cloudimg-amd64.tar.gz"
      "precise" => "http://st-g.de/fileadmin/downloads/2013-05/precise-server-cloudimg-amd64.tar.gz"
      # "precise" => "http://192.168.100.1:8080/precise-server-cloudimg-amd64.tar.gz"
    }
  },
  "mysql" => {
    "allow_remote_root" => true,
    "root_network_acl" => "%"
  },
  "osops_networks" => {
    "public" => "192.168.100.0/24",
    "management" => "192.168.100.0/24",
    "nova" => "192.168.100.0/24"
  },
  "nova" => {
    "debug" => true,
    "network" => {
      "provider" => "quantum",
    #  "fixed_range" => "192.168.100.0/24",
      "public_interface" => "eth1"
    },
    "libvirt" => {
      "virt_type" => "lxc"
    },
    "networks" => [
      {
        "label" => "public",
        "ipv4_cidr" => "10.10.100.0/24",
        "num_networks" => "1",
        "network_size" => "255",
        "bridge" => "br100",
        "bridge_dev" => "eth1",
        "dns1" => "8.8.8.8",
        "dns2" => "8.8.4.4"
      }
    ]
  },
  "horizon" => {
    "platform" => {
      "horizon_packages" => ["node-less","openstack-dashboard", "python-mysqldb", "python-netaddr", "python-cinderclient",
                           "python-quantumclient", "python-keystoneclient", "python-glanceclient", "python-novaclient"]
    }
  }
  )
