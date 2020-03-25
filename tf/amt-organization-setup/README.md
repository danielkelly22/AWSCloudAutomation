# AmTrust Organization Setup

This Terraform template will create your organization, OUs, and Accounts. It will also create and apply Service Control Policies and Tag Policies to the OUs.

<https://docs.aws.amazon.com/organizations/latest/userguide/orgs_introduction.html>

## Adding a new Account

Update the `accounts.auto.tfvars` file to include the new account. Follow the pattern established in that file. Once the changes have been applied, you'll also have to update the amt-accounts-setup workspace to include the account and apply those changes.

<https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_accounts.html>

## Adding new Organizational Units

Add the organizational unit to the `organizational_units.tf` file. Also add the entry to the locals at the bottom of the file. This is important, because any account that references this OU will do so by the name defined in the map under the `organizational_units` element.

<https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_ous.html>

## Adding Service Control Policies (SCPs)

 1. In the `policies` folder, add your new policy.
 1. In the `service_control_policies.tf` file, add an entry for your new policy
 1. In the `servuce_control_policies.tf` file, add an association of your policy to an OU or to the root of the organization.

<https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_scp.html>

## Adding tag policies

 1. In the `policies` folder, add your new policy.
 1. In the `tag_policies.tf` file, add the policy.
 1. In the `tag_policies.tf` file, add an association of your policy to an OU or to the root of the organization.

<https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_tag-policies.html>
