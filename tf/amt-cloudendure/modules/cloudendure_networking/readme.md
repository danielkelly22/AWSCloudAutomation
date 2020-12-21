# Networking

## VPC's

We need the following VPC's:
* Replication VPC - the client agents communicate with ec2 instances that live on a subnet in this VPC.
* DR Test VPC - this VPC is used for DR testing.

Two VPC's are needed because the DR test VPC will require bespoke DHCP options, to point restored test instances 
to a restored domain controller for DNS. DHCP options are a VPC-wide setting, therefore a separate VPC is required.


## Subnets

* Replication VPC - one subnet that has an IGW.
* DR Test VPC
  * One isolated subnet.
  * One jump-box subnet. The jump-box will be multi-homed.


## TGW Attachments

The Replication VPC must be attached for ingress.
The DR test VPC must be attached for jump host access.


## TGW Routes

The replication VPC's subnets must be routed to/from VPN and On-Prem.
The DR test VPC is more complicated and must follow these rules:
* The DR test jump-host subnet must be routed to/from VPN.
* The DR test isolated subnets must have no routes.
* The DR test isolated subnets must be black-holed to/from other VPC's as an additional layer of protection.


## Network ACL's

The DR test isolated subnet must allow no traffic inbound or outbound.


## Security Groups

The DR test VPC must include the following security groups:
* A security group allowing ingress/egress to itself (only). This will be used to allow restored machines to talk 
  to each other.
* A security group allowing the jump-host to be accessed via ICMP and TCP/3389 from the VPN. 


## Subnet Route Tables
The DR test VPC will need a route table for the isolated subnet, which contains no routes other than the 
on-link VPC CIDR's route.

