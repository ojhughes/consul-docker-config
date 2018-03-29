#!/bin/bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
"deb [arch=amd64] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) \
stable"
sudo apt-get update
sudo apt-get -y install docker-ce unzip jq zsh
sudo usermod -G docker vagrant
#Expose Docker API for portainer management
sudo sed -i '/ExecStart=/c\ExecStart=/usr/bin/dockerd -H fd:// -H tcp://0.0.0.0:2376' /lib/systemd/system/docker.service
sudo systemctl daemon-reload
sudo systemctl restart docker.service

#Set up Dummy interface for DNS
sudo ip link add dummy0 type dummy
sudo ip addr add 169.254.1.1/32 dev dummy0
sudo ip link set dev dummy0 up
ip addr show dev dummy0

dns_entry="dns-nameserver ${DNS_HOST} 8.8.8.8"
if ! $(grep -q -F ${dns_entry} /etc/network/interfaces); then
    echo ${dns_entry} | sudo tee --append /etc/network/interfaces
    sudo ifdown eth1
    sudo ifup eth1
fi

#Docker compose
if [[ ! $(type /usr/local/bin/docker-compose) ]]; then
	sudo curl -L https://github.com/docker/compose/releases/download/1.19.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose 2>/dev/null
	sudo chmod +x /usr/local/bin/docker-compose
fi
cp /vagrant/config/docker-compose-common.yml $HOME/docker

#Create .env file for docker containing host private interface IP address
echo "HOST_IP="$(ip address show eth1 | grep 'inet ' | sed -e 's/^.*inet //' -e 's/\/.*$//') > $HOME/docker/.env

#Install Consul
if [[ ! $(type /usr/local/bin/consul) ]]; then
	wget -q https://releases.hashicorp.com/consul/1.0.6/consul_1.0.6_linux_amd64.zip 2> /dev/null
	unzip consul_1.0.6_linux_amd64.zip
	rm consul_1.0.6_linux_amd64.zip
	sudo mv consul /usr/local/bin
	sudo mkdir -p /opt/consul/data
    sudo chown -R vagrant:vagrant /opt/consul
fi

#Install Vault
if [[ ! $(type /usr/local/bin/vault) ]]; then
    wget -O /tmp/vault.zip "https://releases.hashicorp.com/vault/0.9.6/vault_0.9.6_linux_amd64.zip" \
      && sudo unzip -d /usr/local/bin /tmp/vault.zip \
      && sudo chmod 755 /usr/local/bin/vault \
      && rm /tmp/vault.zip
fi

#ZSH
if [[ ! -d $HOME/.oh-my-zsh ]]; then
	git clone --depth 1 https://github.com/robbyrussell/oh-my-zsh.git $HOME/.oh-my-zsh \
	&& echo 'export ZSH=$HOME/.oh-my-zsh' >> $HOME/.zshrc \
	&& echo 'ZSH_THEME="sunaku"' >> $HOME/.zshrc \
	&& echo 'plugins=(git history-substring-search vi-mode)' >> $HOME/.zshrc \
	&& echo 'source $ZSH/oh-my-zsh.sh' >> $HOME/.zshrc \
	&& echo 'export TERM=xterm-256color' >> $HOME/.zshrc \
	&& echo 'alias dc=docker-compose' >> $HOME/.zshrc
	echo 'exec /bin/zsh' >> $HOME/.bashrc
fi

if [[ ! -f $HOME/fzf/bin/fzf ]]; then
	git clone --depth 1 https://github.com/junegunn/fzf.git $HOME/fzf \
	 && $HOME/fzf/install --all 2> /dev/null
fi

#VIM
if [[ ! -d $HOME/.vim ]]; then
	cp /vagrant/config/vimrc $HOME/.vimrc
	cp -r /vagrant/config/vim $HOME/.vim
fi

sudo ufw disable
cd $HOME/docker && sudo docker-compose up -d


