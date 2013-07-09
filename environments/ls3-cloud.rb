name "ls3-cloud"
description "Defines the network and database settings you're going to use with OpenStack. The networks will be used in the libraries provided by the osops-utils cookbook. This example is for FlatDHCP with 2 physical networks."

override_attributes(
  :package_component => "folsom",
  :glance => {
    :image_upload => true,
    :images => ["precise"],
    :image => {
      # "precise" => "https://cloud-images.ubuntu.com/precise/current/precise-server-cloudimg-amd64.tar.gz"
      # "precise" => "http://st-g.de/fileadmin/downloads/2013-05/precise-server-cloudimg-amd64.tar.gz"
      :precise => "http://st-g.de/fileadmin/downloads/2013-05/precise-server-cloudimg-amd64.tar.gz"
    }
  },
  :mysql => {
    :allow_remote_root => true,
    :root_network_acl => "%"
  },
  :osops_networks => {
    :public => "172.16.33.0/24",
    :management => "172.16.33.0/24",
    :nova => "172.16.33.0/24"
  },
  :nova => {
    :config => {
      :log_verbosity => "DEBUG"
    },
    :syslog => {
      :use => false
    },
    :libvirt => {
      :virt_type => "qemu"
    },
    #"network" => {
    #  "fixed_range" => "192.168.100.0/24",
    #  "public_interface" => "eth1"
    #},
    :networks => [
      {
        :label => "public",
        :ipv4_cidr => "10.10.100.0/24",
        # :ipv4_cidr => "172.16.201.0/24",
        :num_networks => "1",
        :network_size => "255",
        :bridge => "br100",
        :bridge_dev => "eth0",
        :dns1 => "132.187.1.13",
        :dns2 => "132.187.1.13"
      }
    ]
  },
  :cinder => {
    :syslog => {
      :use => false
    }
  },
  :quantum => {
    :verbose => "False",
    :debug => "False"
  }
  )
