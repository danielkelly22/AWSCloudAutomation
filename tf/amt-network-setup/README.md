# Network Setup Terraform Configuration

This Terraform workspace is responsible for setting up all of the VPC related resources for AmTrust primary, DR, and sandbox networks.

## VPN

The VPN configuration defines the VPN resources employed in the AmTrust AWS organization. All VPN definitions can be placed in the `vpn.tf` file.

## VPC

All VPCs for the AmTrust AWS organization are defined here. It is divided into two files, `vpc-[environment].tf` and `vpc-[environment].auto.tfvars`. Both must be updated in order to add or remove a VPC.

### vpc-[environment].tf

### vpc-[environment].auto.tfvars

## Transit Gateways

## S3 Buckets

## Palo Alto

## AD DCs

## Modules

### vpc

### transit_gateway

### transit_gateway_route_table

### vpn

### firewall

## Exceptions

Core subnets in Shared Services VPC are public subnets to support TFE requiremnets. Once DNAT is supported through Palo Alto, these public subnets can be removed. See `vpc-shared.auto.tfvars`

## Contributing

Commit the changes to a branch in GitHub, then submit a pull request.

<https://www.hashicorp.com/blog/continuous-integration-for-terraform-modules-with-github-actions/>
