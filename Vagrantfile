Vagrant.configure("2") do |config|

  config.vm.define "default",primary: true do |master|
    # config.vm.network "public_network"
    config.vm.network "forwarded_port", id: "ssh", host: 2222, guest: 22
  end

  config.vm.provider "docker" do |d, override|
    d.image = "toddbu/node-dev-container:2.22.04"
    # d.build_dir = "."
    d.remains_running = true
    d.has_ssh = true
    d.privileged = true
    d.volumes = ["node-dev-home:/home/dev:rw"]
  end

end
