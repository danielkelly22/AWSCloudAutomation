# VPC Module

This module creates a VPC and its constituent components.


## General notes
* Transited subnets are attached to the TGW
* Public subnets have IGW's for ingress until we get a better solution in place.


## TODO
 * transit TGW to route to the cloudendure replication VPC which is currently black-holed.
 * Cloudendure AWS endpoint IP's as egress to the replication servers' security group.
 * what is a nat_subnet, and why is it a map and not a list?
 * why are the public_subnets variable, and the transited_subnets variable, of different types?
   * it's because of this in internet_connectivity.tf:
     ```terraform
     # If there are no public subnets, then this is empty. Otherwise there is a record. This is
     # Since we only need one internet gateway, it's simpler than with the NAT gateways.
     any_public_egress = length(local.public_egress_subnets) == 0 ? [] : ["public-egress"]
     ```
* checklist for adding new VPC's -- ip range from netops then: tgw routes, auto.tfvars, and vpc-env.tf

### General
* spelling on the null_resource
* outputs.tf 'subnet_ids' is a misnomer -- it's outputting a map not a list of ids


### Discussion
* subnet properties
  * it might be worth ripping out nat_subnets, isolated_subnets, public_subnets lists, 
  and instead having a subnet_type property on the subnets object.


### Isolated VPCs

* new variables
  * isolated_vpc (bool)
  * isolated_subnets (set)
* assert isolated_subnets and isolated_vpc and skip_default_sg_modify
* resource changes:
  * locked down network ACL for isolated_subnets
  * blank route table for isolated_subnets


## Refs
[subnet calculator helper](https://blog.ebfe.pw/posts/ipcalcterraform.html)
