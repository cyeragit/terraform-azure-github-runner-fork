#!/bin/bash -x
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

# Script requires four input variables, and accepts additional optional variables, supplied via terraform templatefile()
# runner_labels                 REQUIRED e.g. "azure, vm"
# runner_owner                  REQUIRED e.g. "liatrio-enterprise"
# registration_key_vault_name   REQUIRED e.g. "kv-gh-run-reg-liatriodev"
# runner_sha                    OPTIONAL e.g. "[sha256 sum for runner binary]"
# gh_url                        OPTIONAL e.g. "github.mydomain.com"


# retrieve gh registration token from azure key vault
az login --identity --allow-no-subscription
REGISTRATION_TOKEN=$(az keyvault secret show -n $(hostname) --vault-name ${registration_key_vault_name} | jq -r '.value')
cd /home/ubuntu/actions-runner || exit
runuser -u ubuntu -- bash -c "./config.sh --unattended --ephemeral --replace -labels ${runner_labels} -url https://github.com/${runner_owner} --token ${REGISTRATION_TOKEN}"

# Start the runner
sudo ./svc.sh install
sudo ./svc.sh start