#!/bin/bash
# A script that finalizes Vault configuration on instance startup

# Create auto unseal stanza
cat <<- EOF >> /etc/vault.d/vault.hcl
seal "awskms" {
  kms_key_id = "${kms_key_id}"
  region     = "${region}"
}
EOF

# Create auto-join raft stanza
cat <<- EOF >> /etc/vault.d/vault.hcl
storage "raft" {
  path = "/opt/vault/raft/"
  retry_join {
    leader_api_addr = "http://${alb_dns}"
  }
}$NL
EOF

# Replace 'localhost' with ip of current machine
MY_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
sed -i "s/localhost/$MY_IP/g" /etc/vault.d/vault.hcl

systemctl enable vault
systemctl start vault
