#!/bin/bash

# setup logging and begin
set -e -u -o pipefail
NOW=$(date +"%FT%T")
echo "[$NOW]  Beginning TFE user_data script."

# update packages and install prereqs
sudo apt-get -y update
sudo apt install -y jq awscli unzip
sudo apt install -y python3-pip
pip3 install awscli --upgrade --user

# set up file paths and directories
tfe_installer_dir="/opt/tfe/installer"
tfe_config_dir="/opt/tfe/config"
tfe_settings_path="$tfe_config_dir/tfe-settings.json"
tfe_license_path="$tfe_config_dir/tfe-license.rli"
repl_conf_path="/etc/replicated.conf"

sudo mkdir -p $tfe_installer_dir
sudo mkdir -p $tfe_config_dir

#retrieve TFE license file from S3
aws s3 cp s3://${tfe_bootstrap_bucket}/tfe-license.rli $tfe_config_dir

##########################################################################################################################################################
# RETRIEVE TFE SECRETS FROM CUSTOMERS' SECRETS MANAGEMENT TOOL OF CHOICE
#
# Or, if the customer is comfortable with having secrets in their Terraform State,
#    remove this section and simply add Terraform variables for the two secrets below.
#
# This section is reserved for the retrieval of the following secrets:
#    repl_password - the Replicated console password to unlock the Replicated Dashboard
#    enc_password  - the encyrption password protecting embedded Vault's unseal key & root token
#
# The two most common secrets management tools we've seen used here are HashiCorp Vault & AWS Secrets Manager
#    - leverage the EC2 IAM instance role to auth to the secrets management tool of choice
#
# Programmatically retrieve the secrets & store them as variables to later be plugged in:
#    $repl_password - used in /etc/replicated.conf config file (see line 52)
#    $enc_password  - used in tfe-settings.json config file (see line 83)
#
# AWS SECRETS MANAGER EXAMPLE:
# aws secretsmanager get-secret-value --region 'us-east-1' --secret-id <arn of secret> --query SecretString --output text | jq -r '.repl_password'
# aws secretsmanager get-secret-value --region 'us-east-1' --secret-id <arn of secret> --query SecretString --output text | jq -r '.enc_password'
#
# HASHICORP VAULT EXAMPLE:
# latest_vault_url=$(curl -sL https://releases.hashicorp.com/vault/index.json | jq -r '.versions[].builds[].url' | egrep 'vault_[0-9]\.[0-9]{1,2}\.[0-9]{1,2}_linux.*amd64' | sort -V | tail -1)
# curl -sL -o /tmp/vault.zip $latest_vault_url
# sudo unzip /tmp/vault.zip -d /usr/local/bin
# export VAULT_ADDR='<vault-hostname>:8200'
# VAULT_TOKEN=$(vault login -token-only -method=aws role=<my-vault-aws-role>)
# export VAULT_TOKEN=$VAULT_TOKEN
# repl_password=$(vault kv get -format=json secret/tfe/repl_password | jq -r '.data.data.value')
# enc_password=$(vault kv get -format=json secret/tfe/enc_password | jq -r '.data.data.value')
#
##########################################################################################################################################################

# retrieve secrets from AWS Secrets Manager
repl_password=$(aws secretsmanager get-secret-value --region ${tfe_app_bucket_region} --secret-id ${aws_secret_arn} --query SecretString --output text | jq -r '.repl_password')
enc_password=$(aws secretsmanager get-secret-value --region ${tfe_app_bucket_region} --secret-id ${aws_secret_arn} --query SecretString --output text | jq -r '.enc_password')

# retrieve TFE install bits
sudo curl -o $tfe_installer_dir/install.sh https://install.terraform.io/ptfe/stable

# create Replicated bootstrap config file
cat > $repl_conf_path <<EOF
{
  "DaemonAuthenticationType": "password",
  "DaemonAuthenticationPassword": "$repl_password",
  "TlsBootstrapType": "self-signed",
  "TlsBootstrapHostname": "${tfe_hostname}",
  "TlsBootstrapCert": "",
  "TlsBootstrapKey": "",
  "BypassPreflightChecks": true,
  "ImportSettingsFrom": "$tfe_settings_path",
  "LicenseFileLocation": "$tfe_license_path",
  "LicenseBootstrapAirgapPackagePath": ""
}
EOF

# create TFE settings bootstrap config file
cat > $tfe_settings_path <<EOF
{
    "aws_access_key_id": {},
    "aws_instance_profile": {
        "value": "1"
    },
    "aws_secret_access_key": {},
    "ca_certs": {},
    "capacity_concurrency": {
        "value": "10"
    },
    "capacity_memory": {
        "value": "512"
    },
    "enable_metrics_collection": {
        "value": "1"
    },
    "enc_password": {
        "value": "$enc_password"
    },
    "extern_vault_addr": {},
    "extern_vault_enable": {
        "value": "0"
    },
    "extern_vault_path": {},
    "extern_vault_propagate": {},
    "extern_vault_role_id": {},
    "extern_vault_secret_id": {},
    "extern_vault_token_renew": {},
    "extra_no_proxy": {},
    "hostname": {
        "value": "${tfe_hostname}"
    },
    "iact_subnet_list": {},
    "iact_subnet_time_limit": {
        "value": "60"
    },
    "installation_type": {
        "value": "production"
    },
    "pg_dbname": {
        "value": "${pg_dbname}"
    },
    "pg_extra_params": {
        "value": "sslmode=require"
    },
    "pg_netloc": {
        "value": "${pg_netloc}"
    },
    "pg_password": {
        "value": "${pg_password}"
    },
    "pg_user": {
        "value": "${pg_user}"
    },
    "placement": {
        "value": "placement_s3"
    },
    "production_type": {
        "value": "external"
    },
    "s3_bucket": {
        "value": "${tfe_app_bucket_name}"
    },
    "s3_endpoint": {},
    "s3_region": {
        "value": "${tfe_app_bucket_region}"
    },
    "s3_sse": {
        "value": "aws:kms"
    },
    "s3_sse_kms_key_id": {
        "value": "${kms_key_arn}"
    },
    "tbw_image": {
        "value": "default_image"
    },
    "tls_vers": {
        "value": "tls_1_2_tls_1_3"
    }
}
EOF

# collect AWS EC2 instance metadata
EC2_PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

# execute the TFE installer script with arguments
cd $tfe_installer_dir
bash ./install.sh \
    no-proxy \
    release-sequence=${tfe_release_sequence} \
    private-address=$EC2_PRIVATE_IP \
    public-address=$EC2_PRIVATE_IP

# sleep at beginning of TFE install
NOW=$(date +"%FT%T")
echo "[$NOW]  Sleeping for 2 minutes while TFE initializes..."
sleep 120

# poll install status against TFE health check endpoint
while ! curl -ksfS --connect-timeout 5 https://$EC2_PRIVATE_IP/_health_check; do
    sleep 5
done

# end script
NOW=$(date +"%FT%T")
echo "[$NOW]  Finished TFE user_data script."
