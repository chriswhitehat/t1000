# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.

  # config.vm.box_download_insecure = true
  
  config.proxy.http     = "http://proxy.ghc.org:8080"
  config.proxy.https    = "http://proxy.ghc.org:8080"
  config.proxy.no_proxy = "localhost,127.0.0.1,ghc.org"

  config.butcher.verify_ssl = false

  config.ssh.guest_port = 52222
  config.ssh.guest_port = 22

  config.vm.define "opencanary01" do |opencanary|
    opencanary.vm.box = "ubuntu/xenial64"
    opencanary.vm.hostname = "opencanary01"
    opencanary.vm.network "private_network", ip: "192.168.50.10", virtualbox__intnet: "white_network"
    opencanary.vm.network :forwarded_port, guest: 22, host: 22000, id: 'ssh'
    config.vm.provider :virtualbox do |vb|
      vb.linked_clone = true
      vb.customize ["modifyvm", :id, "--memory", "1024"]
      vb.customize ['modifyvm', :id, '--natnet1', '192.168.222.0/24']
      vb.customize ['modifyvm', :id, "--natdnshostresolver1", "off"]
    end

    opencanary.vm.provision "chef_client" do |client|
      client.chef_server_url = "https://esa-ir-dca.ghc.org/organizations/ghc"
      client.validation_client_name = "ghc-validator"
      client.validation_key_path = "../../.chef/ghc-validator.pem"
      client.add_role "base"
      client.add_recipe "kp_pots::opencanary01"
    end
  end

  config.vm.define "opencanary02" do |opencanary|
    opencanary.vm.box = "ubuntu/xenial64"
    opencanary.vm.hostname = "opencanary02"
    opencanary.vm.network "private_network", ip: "192.168.50.11", virtualbox__intnet: "white_network"
    opencanary.vm.network :forwarded_port, guest: 22, host: 22001, id: 'ssh'
    config.vm.provider :virtualbox do |vb|
      vb.linked_clone = true
      vb.customize ["modifyvm", :id, "--memory", "1024"]
      vb.customize ['modifyvm', :id, '--natnet1', '192.168.222.0/24']
      vb.customize ['modifyvm', :id, "--natdnshostresolver1", "off"]
    end

    opencanary.vm.provision "chef_client" do |client|
      client.chef_server_url = "https://esa-ir-dca.ghc.org/organizations/ghc"
      client.validation_client_name = "ghc-validator"
      client.validation_key_path = "../../.chef/ghc-validator.pem"
      client.add_role "base"
      client.add_recipe "t1000"
      client.add_recipe "kp_bro"

    end
  end
end
