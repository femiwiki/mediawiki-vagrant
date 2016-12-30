Vagrant.configure("2") do |config|
  config.vm.define "www" do |c|
    c.vm.box = "ubuntu/xenial64"
    c.vm.network "private_network", ip: "192.168.50.10"
    c.vm.provider :virtualbox do |v|
      v.memory = 1024
      v.cpus = 1
    end
  end

  config.vm.define "parsoid" do |c|
    c.vm.box = "ubuntu/xenial64"
    c.vm.network "private_network", ip: "192.168.50.11"
    c.vm.provider :virtualbox do |v|
      v.memory = 1024
      v.cpus = 1
    end
  end
end
