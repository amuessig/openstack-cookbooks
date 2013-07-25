name "ls3-openstack"

override_attributes({
  :openstack => {
    :developer_mode => true
  },
  :glance => {
    :debug => "True"
  },
  :keystone => {
    :bind_interface => "eth1",
    :db => {
      :password => "fooo"
    }
  }
})
