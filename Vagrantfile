domain = "openstack.vagrant"
ip_prefix = "192.168.100"

boxes = [
  {
    :name        => :allinone,
    :memory      => 4096,
    :cpus        => 4,
    :run_list    => ['role[allinone]', 'recipe[ls3-openstack]'],
    :ip          => 11,
  },
  {
    :name        => :singlecompute1,
    :memory      => 1024,
    :cpus        => 1,
    :run_list    => ['role[single-compute]'],
    :ip          => 12,
  }
]

Vagrant.configure("2") do |config|

  # VAGRANT_BOX (like all the other ENV['...']) is an environment variable,
  # which can be set for the current shell session via
  #   $ export VAGRANT_BOX=wheezy
  # or can be added to your shell profile (e.g. ~/.bash_profile)
  base_box = ENV['VAGRANT_BOX'] || "ubuntu-13.04"

  config.vm.box = base_box
  # config.vm.synced_folder "./tmp/apt-cache/#{base_box}", "/var/cache/apt", :create => true

  # this requires vagrant-omnibus plugin (`vagrant plugin install vagrant-omnibus`)
  config.omnibus.chef_version = ENV['VAGRANT_CHEF_VERSION'] || :latest

  # this requires the vagrant-hostmanager plugin (`vagrant plugin install vagrant-hostmanager`)
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.ignore_private_ip = false


  #############################################################################################
  # Chef-Server
  #############################################################################################
  config.vm.define "chef-server" do |chef_server|

    hostname = "chef-server.#{domain}"
    config.vm.hostname = hostname

    memory = 512
    cpus   = 1
    gui    = true
    ip     = 10

    chef_server.vm.network :private_network, ip: "#{ip_prefix}.#{ip}"

    # Provider
    chef_server.vm.provider :virtualbox do |vbox|
      vbox.gui = gui
      vbox.customize ["modifyvm", :id, "--memory", memory]
      vbox.customize ["modifyvm", :id, "--cpus",   cpus]
      vbox.name = hostname
    end
    chef_server.vm.provider :vmware do |vmware|
      vmware.gui = gui
      vmware.vmx['memsize'] = memory
      vmware.vmx['numvcpus'] = cpus
      vmware.vmx['displayName'] = hostname
    end

    # Provisioner
    chef_server.vm.provision :shell do |shell|
      shell.args = "chef-server_11.0.8-1.ubuntu.12.04_amd64.deb"
      shell.inline = "
        if test ! -f /home/vagrant/$1; then
          wget https://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/12.04/x86_64/$1;
          dpkg -i $1;
          sudo chef-server-ctl reconfigure;
          echo;
          echo Your admin.pem:;
          cat /etc/chef-server/admin.pem;
          echo;
          echo Your validator.pem:;
          cat /etc/chef-server/chef-validator.pem;
        fi"
    end
  end


  #############################################################################################
  # loop through all defined boxes
  #############################################################################################
  boxes.each do |opts|
    config.vm.define opts[:name] do |config|

      memory = opts[:memory] || 512
      cpus   = opts[:cpus]   || 2
      ip     = "#{ip_prefix}.#{opts[:ip]}"
      gui    = opts[:gui]    || false

      config.vm.hostname =  "%s.#{domain}" % opts[:name].to_s
      config.vm.network :private_network, ip: ip
      # config.vm.network :private_network, ip: "10.10.100.2"
      # config.vm.network :forwarded_port, guest: 80, host: opts[:http_port], id: "http" if opts[:http_port]

      # Provider
      config.vm.provider :virtualbox do |vbox|
        vbox.gui = gui
        vbox.customize ["modifyvm", :id, "--memory", memory]
        vbox.customize ["modifyvm", :id, "--cpus",   cpus]
        vbox.name = "%s.#{domain}" % opts[:name].to_s
      end
      config.vm.provider :vmware do |vmware|
        vmware.gui = gui
        vmware.vmx['memsize'] = memory
        vmware.vmx['numvcpus'] = cpus
        vmware.vmx['displayName'] = "%s.#{domain}" % opts[:name].to_s
      end

      # Provisioner
      config.vm.provision :hostmanager
      config.vm.provision :chef_client do |chef|
        chef.chef_server_url     = "https://chef-server.#{domain}"
        chef.validation_key_path = ".chef/openstack-validator-vagrant.pem"
        chef.environment         = "vagrant"
        chef.run_list            = opts[:run_list]
        chef.log_level           = ENV['CHEF_LOG_LEVEL'] || :info
      end
    end
  end
end

