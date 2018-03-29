# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # Example settings
  # config.vm.network "forwarded_port", guest: 80, host: 8080
  # config.vm.synced_folder "../data", "/vagrant_data"
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL
  hosts = YAML::load(File.read("#{File.dirname(__FILE__)}/hosts.yml"))

  config.vm.define "consul" do |consul|

    consul.vm.host_name = hosts["consul"]["fqdn"]
    consul.vm.box = "bento/ubuntu-16.04"
    consul.vm.network "private_network", ip: hosts["consul"]["ip"]
    consul.vm.provider "virtualbox" do |vb|
      vb.memory = "512"
      vb.auto_nat_dns_proxy = false
      vb.customize ["modifyvm", :id, "--natdnsproxy1", "off"]
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "off"]
    end
    consul.vm.provision "shell",:run => 'always',:privileged => false,  inline: <<-SHELL
     mkdir -p $HOME/docker
     cp /vagrant/config/docker-compose-consul.yml $HOME/docker/docker-compose.yml
     SHELL
    consul.vm.provision "shell", :run => 'always',:privileged => false, :path => 'config/provision-dns.sh',
                        :env=> {CONSUL_HOST:hosts['consul'].to_json,
                                VAGRANT_HOST:hosts['vagrant'].to_json,
                                APP1_HOST:hosts['app1'].to_json,
                                APP2_HOST:hosts['app2'].to_json,
                                PORTAINER_HOST:hosts['portainer'].to_json,
                        }
    consul.vm.provision "shell", :run => 'always',:privileged => false, :path => 'config/provision-vagrant.sh', :env => {DNS_HOST: hosts['consul']['ip']}
  
  end    

  config.vm.define "vault" do |vault|
    vault.vm.host_name = hosts["vault"]["fqdn"]
    vault.vm.box = "bento/ubuntu-16.04"
    vault.vm.network "private_network", ip: hosts["vault"]["ip"]
    vault.vm.provider "virtualbox" do |vb|
      vb.memory = "512"
      vb.auto_nat_dns_proxy = false
      vb.customize ["modifyvm", :id, "--natdnsproxy1", "off"]
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "off"]
    end
    vault.vm.provision "shell",:run => 'always',:privileged => false,  inline: <<-SHELL
     mkdir -p $HOME/docker
     cp /vagrant/config/docker-compose-vault.yml $HOME/docker/docker-compose.yml
     SHELL
    vault.vm.provision "shell", :run => 'always',:privileged => false, :path => 'config/provision-vagrant.sh', :env => {DNS_HOST: hosts['consul']['ip']}
    vault.vm.provision "shell", :run => 'always',:privileged => false, :path => 'config/vault-init.sh'
  end

  config.vm.define "app1" do |app1|
    app1.vm.host_name = hosts["myapp1"]["fqdn"]
    app1.vm.box = "bento/ubuntu-16.04"
    app1.vm.network "private_network", ip: hosts["myapp1"]["ip"]
    app1.vm.provider "virtualbox" do |vb|
      vb.memory = "512"
      vb.auto_nat_dns_proxy = false
      vb.customize ["modifyvm", :id, "--natdnsproxy1", "off"]
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "off"]
    end
    app1.vm.provision "shell",:run => 'always',:privileged => false,  inline: <<-SHELL
     mkdir -p $HOME/docker
     cp /vagrant/config/docker-compose-app.yml $HOME/docker/docker-compose.yml
     SHELL
    app1.vm.provision "shell", :run => 'always',:privileged => false, :path => 'config/provision-vagrant.sh', :env => {DNS_HOST: hosts['consul']['ip']}
    app1.vm.provision "shell", :run => 'always', :privileged => false, inline: <<-SHELL
     cd /vagrant/cloud-native-config-app/
     docker build --rm -t ojhughes/cloud-native-config-app .
    SHELL
  end

  config.vm.define "app2" do |app2|
    app2.vm.host_name = hosts["myapp2"]["fqdn"]
    app2.vm.box = "bento/ubuntu-16.04"
    app2.vm.network "private_network", ip: hosts["myapp2"]["ip"]
    app2.vm.provider "virtualbox" do |vb|
      vb.memory = "512"
      vb.auto_nat_dns_proxy = false
      vb.customize ["modifyvm", :id, "--natdnsproxy1", "off"]
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "off"]
    end
    app2.vm.provision "shell",:run => 'always',:privileged => false,  inline: <<-SHELL
     mkdir -p $HOME/docker
     cp /vagrant/config/docker-compose-app.yml $HOME/docker/docker-compose.yml
     SHELL
    app2.vm.provision "shell", :run => 'always',:privileged => false, :path => 'config/provision-vagrant.sh', :env => {DNS_HOST: hosts['consul']['ip']}
  end


  config.vm.define "portainer" do |portainer|
    portainer.vm.host_name = hosts["portainer"]["fqdn"]
    portainer.vm.box = "bento/ubuntu-16.04"
    portainer.vm.network "private_network", ip: hosts["portainer"]["ip"]
    portainer.vm.provider "virtualbox" do |vb|
      vb.memory = "512"
      vb.auto_nat_dns_proxy = false
      vb.customize ["modifyvm", :id, "--natdnsproxy1", "off"]
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "off"]
    end
    portainer.vm.provision "shell", :run =>'always', :privileged => false, inline: <<-SHELL
     mkdir -p $HOME/docker/portainer-endpoints
     cp /vagrant/config/endpoints.json $HOME/docker/portainer-endpoints
     cp /vagrant/config/docker-compose-portainer.yml $HOME/docker/docker-compose.yml
     SHELL
    portainer.vm.provision "shell", :run => 'always', :privileged => false,:path => 'config/provision-vagrant.sh', :env => {DNS_HOST: hosts['consul']['ip']}
  end

end
