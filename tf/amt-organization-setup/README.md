# AmTrust Organization Setup

This Terraform template will create your organization, OUs, and Accounts. It will also create and apply Service Control Policies and Tag Policies to the OUs.

## Adding a new Account

Update the "accounts.tf" file to include the new account. Follow the pattern established in that file. Once the changes have been applied, you'll also have to update the amt-account-bootstrap templates to include the account and apply those changes.
