# main
tfe_hostname         = "tfe.amtrustgroup.com"
friendly_name_prefix = "tfe"
common_tags          = {}
tfe_release_sequence = ""
tfe_bootstrap_bucket = "tfesharedservicessecrets"

# network
vpc_id         = "vpc-0709e462c67f9a26e"
alb_subnet_ids = ["subnet-0018c69704ac4e06d", "subnet-0d854a74a97f6e236"]
ec2_subnet_ids = ["subnet-09670609fe5a4ce69", "subnet-068c25baa85c1e54c"]

# security
tfe_ingress_cidr_web_allow = ["0.0.0.0/0"]
tfe_ingress_cidr_ec2_allow = ["0.0.0.0/0"]
tfe_ec2_key_pair           = "TFE_key"
kms_key_arn                = "arn:aws:kms:us-east-1:207476187760:key/90943100-0695-41a1-9aca-268d6cd1d9c7"
secrets_mgmt               = "aws"
aws_secret_arn             = "arn:aws:secretsmanager:us-east-1:207476187760:secret:TFE_bootstrap_secrets-MZ98ku"

# compute
tfe_os_type = "ubuntu"
tfe_ami     = "ami-07ebfd5b3428b6f4d"

# storage
rds_subnet_ids = ["subnet-0018c69704ac4e06d", "subnet-0d854a74a97f6e236"]
