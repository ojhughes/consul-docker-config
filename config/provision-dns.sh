#!/usr/bin/env bash
set -e
set -u
set -o pipefail
[[ -z ${CONSUL_HOST} ]] && (>&2 echo "CONSUL_HOST variable not set")  && exit 1
[[ -z ${VAGRANT_HOST} ]] && (>&2 echo "VAGRANT_HOST variable not set")  && exit 1
[[ -z ${APP1_HOST} ]] && (>&2 echo "APP1_HOST variable not set")  && exit 1
[[ -z ${APP2_HOST} ]] && (>&2 echo "APP2_HOST variable not set")  && exit 1
[[ -z ${PORTAINER_HOST} ]] && (>&2 echo "PORTAINER_HOST variable not set")  && exit 1

HOSTS_FILE=${HOME}/docker/dnsmasq-hosts.txt
add_to_host_file_if_not_present() {
    local host_json=$1
    local hosts_entry=$(echo ${host_json} | jq  '.[]' | jq --slurp -r '. | join(" ")')
    grep -q -F ${hosts_entry} ${HOSTS_FILE} || echo ${hosts_entry} | sudo tee --append ${HOSTS_FILE} >/dev/null
}
sudo apt-get update
sudo apt-get -y install jq

cp /vagrant/config/dnsmasq.conf $HOME/docker

add_to_host_file_if_not_present ${CONSUL_HOST}
add_to_host_file_if_not_present ${VAGRANT_HOST}
add_to_host_file_if_not_present ${APP1_HOST}
add_to_host_file_if_not_present ${APP2_HOST}
add_to_host_file_if_not_present ${PORTAINER_HOST}