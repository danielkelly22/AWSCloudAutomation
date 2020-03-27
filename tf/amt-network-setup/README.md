# Network Setup Terraform Configuration

This Terraform workspace is responsible for setting up all of the VPC related resources for AmTrust primary, DR, and sandbox networks.

## VPN

The VPN configuration defines the VPN resources employed in the AmTrust AWS organization. All VPN definitions can be placed in the `vpn.tf` file.

## VPC

All VPCs for the AmTrust AWS organization are defined here. It is divided into two files, `vpc-[environment].tf` and `vpc-[environment].auto.tfvars`. Both must be updated in order to add or remove a VPC.

### `providers.tf`

This file is where all of the providers are defined. If you add a VPC in a new account, add the provider to this account. Try to keep the providers in alphabetical order to make it easier to find.

### `vpc-[environment].tf`

These files provisions the VPC. If an environment has multiple VPCs (e.g. primary, dr, sandbox), they should all be defined in this file. This makes it easier to locate all of the VPCs for an environment.

### `vpc-[environment].auto.tfvars`

This file defines the VPC. Each `vpc-[environment].tf` file should have a corresponding `vpc-[environment].auto.tfvars` file. In addition, the variable defined in this file should be declared in the `variables.tf` file.

## `tgw-gateways.tf` and `tgw-routes-[environment].tf`

These files define the transit gateways and their routes.

The `tgw-gateways.tf` file is where the transit gateways are created. If you are adding a new gateway do it here. During VPC creation, the ID for the gateways is passed to the VPCs, which then attach to those gateways.

Since gateway routing requires all of the VPCs to be created first, routing is done after the VPCs are created. For each environment attached to the route, there should be a corresponding `tgw-routes-[environment].tf` file.

## S3 Buckets

S3 buckets that are not attached to a specific workload can be created in the `s3-buckets.tf` file. This makes it easier to audit S3 bucket creation in one place.

## Palo Alto

The Palo Alto firewall resources are found in the `firewalls.tf` file.

## AD DCs

The AD DC resources are found in the `domain-controllers.tf` file.

## Modules

Local (inline) modules promote easier maintenance by moving the complexity of provisioning resources into a cohesive set of files. The modules described below.

### vpc

The VPC module encapsulates several aspects of VPC creation:

* The VPC itself <https://docs.aws.amazon.com/vpc/latest/userguide/getting-started-ipv4.html>
* The VPC subnets <https://docs.aws.amazon.com/vpc/latest/userguide/working-with-vpcs.html>
* The route default route table <https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Route_Tables.html>
* The default security group <https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html>
* The transit gateway attachment <https://docs.aws.amazon.com/vpc/latest/tgw/tgw-vpc-attachments.html>
* Any subnets shared with different accounts <https://docs.aws.amazon.com/vpc/latest/userguide/vpc-sharing.html>
* Secure connection, routing, and default security group access to S3 via VPC endpoints <https://docs.aws.amazon.com/vpc/latest/userguide/vpce-gateway.html>
* Creation of an internet gateway if needed with appropriate public subnet routing <https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Internet_Gateway.html>
* Creation of a NAT gateway if needed with appropriate private subnet routing <https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html>

#### VPC Module Usage

```terraform
module "shared_vpc" {
  source = "./modules/vpc"
  providers = {
    aws        = aws.shared # The account that the VPC will be deployed to
    aws.shared = aws.shared # The shared account. This is used to establish the transit gateway attachment.
  }

  # the transit_gateway_id must be included
  transit_gateway_id                 = module.tgw.tgw_id

  # There should be an entry with the VPC details in the .auto.tfvars file for the environment
  vpc_details                        = var.shared_vpc_details.primary

  # Only skip gateway attachment if the VPC is in the same account as the transit gateway
  skip_gateway_attachment_acceptance = true

  # Any AWS VPC CIDR blocks that this VPC can route to. For most application VPCs, this will be shared services and transit
  aws_routable_cidr_blocks = {
    transit = local.all_cidr_addresses.transit.primary
  }

  # Always include tags. The module may add additional tags or override what was passed.
  tags = module.shared_tags.tags
}
```

### transit_gateway

The transit_gateway module provisions a transit gateway.

<https://docs.aws.amazon.com/vpc/latest/tgw/tgw-getting-started.html>

#### Usage

```hcl
module "tgw" {
  # The shared account in which the transit gateway will be deployed
  providers = { aws = aws.shared }

  source = "./modules/transit_gateway"

  # The name of the transit gateway. Leave this blank to use the default name. This propery is only used because existing transit gateways cannot be named. Renaming them will cause them to be destroyed and replaced.
  description = "Transit Transit Gateway"

  tags = module.tgw_tags.tags
}
```

### transit_gateway_route_table

This applies routes to the transit gateway attachments for a VPC or VPN.

<https://docs.aws.amazon.com/vpc/latest/tgw/tgw-route-tables.html>

### Transit Gateway Route Table Module Usage

```hcl
module "tgw_rt_dev" {
  # The account to which the route will be applied. This must be the same account and region that the transit gateway was provisioned in.
  providers = { aws = aws.shared }

  source = "./modules/transit_gateway_route_table"

  # This is added to the names of resources created (e.g. "foo" might create a resource "amt-foo-route)
  environment_affix             = var.dev_vpc_details.primary.environment_affix

  # The ID of the transit gateway
  transit_gateway_id            = module.tgw.tgw_id

  # The ID of the attachment to the transit gateway.
  transit_gateway_attachment_id = module.dev_vpc.transit_gateway_attachment_id

  # The routes that are attached to the transit VPC. These may vary depending on the VPC.
  attachment_routes = {
    vpn = { # Routes RFC-1918 IP addresses to the VPN
      cidr_blocks   = values(local.local_addresses)
      attachment_id = module.vpn.transit_gateway_attachment_id
    }
    internet-outbound = { # Fallback routes (except black hole routes) goes to the transit gateway
      cidr_blocks   = ["0.0.0.0/0"]
      attachment_id = module.transit_vpc.transit_gateway_attachment_id
    }
    shared-vpc = { # Route shared VPC traffic to the transit gateway
      cidr_blocks   = [var.shared_vpc_details.primary.cidr_block]
      attachment_id = module.shared_vpc.transit_gateway_attachment_id
    }
    transit-vpc = { # Route transit VPC traffic to the transit gateway
      cidr_blocks   = [var.transit_vpc_details.primary.cidr_block]
      attachment_id = module.transit_vpc.transit_gateway_attachment_id
    }
  }

  # Blackhole routes will not be routed
  blackhole_routes = {
    production = var.prod_vpc_details.primary.cidr_block
    uat        = var.uat_vpc_details.primary.cidr_block
  }

  tags = module.tgw_tags.tags
}
```

### vpn

Creates a VPN. More specifically, this allows you to manage a VPN connection that has already been set up.

#### VPN Module Usage

```hcl
module "vpn" {
  # The account to deploy the VPN in to
  providers = {
    aws = aws.shared
  }

  source = "./modules/vpn"

  # The environment name to be affixed to the resource name
  environment_affix  = "shared"

  # The ID of the transit gateway that the VPN will be attached to
  transit_gateway_id = module.tgw.tgw_id

  tags               = module.shared_tags.tags
}
```

#### Importing VPN Module Resources

It may be easier to create the VPN manually and import it into the Terraform configuration after it has been created and validated. To do this, do the following.

1. Set up the module call (see "[VPN Module Usage](#markdown-header-vpn-module-usage)" above)
1. Locate the Customer Gateway in the AWS console (under "VPC>Customer Gateways")
1. Copy the ID for the gateway (should start with "cgw-")
1. Import this to the module created in step 1. `terraform import module.[modulename].aws_customer_gateway.main_gateway cgw-#################`
1. Locate the Site-to-Site VPN in the AWS console (under "VPC>Site-to-Site VPN")
1. Copy the ID from the connection (should start with "vpn-")
1. Import this to the module created in step 1. `terraform import module.[modulename].aws_vpn_connection.main_vpn_connection vpn-#################`

### firewall

Sets up the Palo Alto pair.

#### Usage

```hcl
module "firewalls" {
  # The account where the firewalls will be deployed
  providers = {
    aws = aws.shared
  }

  source = "./modules/firewall"

  # The AMI to use for provisioning
  palo_ami             = var.palo_ami

  # The name of the key pair key to use
  server_key_name      = var.palo_key_name

  # The ID of the public subnet
  public_subnet_id     = module.transit_vpc.subnet_ids["amt-transit-public-subnet-a"]

  # The ID of the private subnet
  private_subnet_id    = module.transit_vpc.subnet_ids["amt-transit-private-subnet-a"]

  # The ID of the management subnet
  management_subnet_id = module.transit_vpc.subnet_ids["amt-transit-mgmt-subnet-a"]

  tags = module.transit_tags.tags
}
```

## Exceptions

Core subnets in Shared Services VPC are public subnets to support TFE requiremnets. Once DNAT is supported through Palo Alto, these public subnets can be removed. See `vpc-shared.auto.tfvars`

## Contributing

Commit the changes to a branch in GitHub, then submit a pull request.

<https://www.hashicorp.com/blog/continuous-integration-for-terraform-modules-with-github-actions/>
