#!/bin/bash -x
set -e

cr=`echo '\n.'`
cr=${cr%.}


cget() { curl -sf "http://consul.service.consul:8500/v1/kv/service/vault/$1?raw"; }

export VAULT_ADDR=http://vault.host.test:8200
if [ ! $(cget root-token) ]; then
  echo "Initialize Vault"
  vault operator init | tee /tmp/vault.init > /dev/null

  # Store master keys in consul for operator to retrieve and remove
  COUNTER=1
  cat /tmp/vault.init | grep '^Unseal' | awk '{print $4}' | for key in $(cat -); do
    curl -fX PUT consul.service.consul:8500/v1/kv/service/vault/unseal-key-$COUNTER -d $key
    COUNTER=$((COUNTER + 1))
  done

  export ROOT_TOKEN=$(cat /tmp/vault.init | grep '^Initial' | awk '{print $4}')
  curl -fX PUT consul.service.consul:8500/v1/kv/service/vault/root-token -d $ROOT_TOKEN

  echo "Remove master keys from disk"
  rm /tmp/vault.init

else
  echo "Vault has already been initialized, skipping."
fi

echo "Unsealing Vault"
vault unseal $(cget unseal-key-1)
vault unseal $(cget unseal-key-2)
vault unseal $(cget unseal-key-3)

if [ ! $(cget config-app-1-token) ]; then
    export VAULT_TOKEN=$(cget root-token)
    app_token=$(vault token create -display-name=app1-token -field=token)
    curl -fX PUT consul.service.consul:8500/v1/kv/service/vault/config-app-1-token -d ${app_token}
    echo "Created app 1 token"
fi

if [ ! $(cget config-app-2-token) ]; then
    export VAULT_TOKEN=$(cget root-token)
    app_token=$(vault token create -display-name=app2-token -field=token)
    curl -fX PUT consul.service.consul:8500/v1/kv/service/vault/config-app-2-token -d ${app_token}
    echo "Created app 2 token"
fi

echo "Vault setup complete."

instructions() {
  cat <<EOF
We use an instance of HashiCorp Vault for secrets management.
It has been automatically initialized and unsealed once. Future unsealing must
be done manually.
The unseal keys and root token have been temporarily stored in Consul K/V.
  /service/vault/root-token
  /service/vault/unseal-key-{1..5}
Please securely distribute and record these secrets and remove them from Consul.
EOF

exit 0
}

instructions
