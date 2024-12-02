#!/bin/bash -x
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

# Script requires four input variables, and accepts additional optional variables, supplied via terraform templatefile()
# runner_labels                 REQUIRED e.g. "azure, vm"
# runner_owner                  REQUIRED e.g. "liatrio-enterprise"
# registration_key_vault_name   REQUIRED e.g. "kv-gh-run-reg-liatriodev"

# retain variable setup for later dependent step(s)
USER_NAME=${runner_username}

# retrieve gh registration token from azure key vault
az login --identity --allow-no-subscription
export REGISTRATION_TOKEN=$(az keyvault secret show -n $(hostname) --vault-name ${registration_key_vault_name} | jq -r '.value')


sudo -b -i -u "${USER_NAME}" --preserve-env=REGISTRATION_TOKEN <<EOF
cd actions-runner

./config.sh \
  --unattended \
  --ephemeral \
  --replace \
  --runnergroup ${runner_group} \
  --labels ${runner_labels} \
  --url https://github.com/${runner_owner} \
  --token $${REGISTRATION_TOKEN}

./run.sh
EOF
