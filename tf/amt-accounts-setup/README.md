# Account Setup

This Terraform configuration is responsible for bootstrapping the governance tooling for each account. They must first be created in the `amt-organization-setup` configuration. Once they are, follow the instructions below for adding a new account

## AWS Landing Zone

The baselines applied conform to the guidance provided by the [AWS Landing Zone](https://aws.amazon.com/solutions/aws-landing-zone)

For details on implementation of the baseline, refer to the security baseline module:

* TFE: <https://tfe.amtrustgroup.com/app/AmTrust/modules/view/security-baseline>
* GitHub (dot com): <https://github.com/amtrust/terraform-aws-security-baseline>

## Adding an account

1. Add the account details to the `accounts.auto.tfvars` file
1. Create a file `acct-[environment].tf`.
1. Copy the text from a simlar file and paste into the new file
1. Change the local variable to reference your new account. Don't forget to rename the local too
1. Change the provider and its alias to reference your new account
1. Update the tags module. Don't forget to also update the module name
1. Update the baseline module. Also don't forget to update the name
1. Add budgets
1. Create any additional resources that are not specific to a workload (shared for workloads in the account)
1. Enjoy

## Referencing the security baseline module

Most of the work happens in the `security_baseline` TFE module. 

```hcl
module "omnius_prod_baseline" {
  providers = {
    aws          = aws.omniusprod # The account that is being baselined
    aws.logarch  = aws.logarch    # The log archive account (for write-only log exports)
    aws.security = aws.security   # The security account (for Guard Duty)
  }

  source  = "tfe.amtrustgroup.com/AmTrust/security-baseline/aws"
  version = ">= 0.5.0"

  # This gets added to the resource names
  environment_affix      = local.omniusprodacct.environment_affix

  # The bucket name of the resource that will receive the logs
  log_archive_s3_bucket  = aws_s3_bucket.log_archive.bucket

  # The email of the account that is being baselined
  account_email          = local.omniusprodacct.email

  # The ID of the guardduty in the security account. If this is security account, don't use this. Use   "is_guardduty_member = false" instead.
  guardduty_master_id    = module.security_baseline.guardduty_id

  # If this is not set, it will block public access to S3 in the entire account. Set it to false to override this behavior.
  block_public_s3_access = false

  tags = module.omnius_prod_tags.tags
}
```
