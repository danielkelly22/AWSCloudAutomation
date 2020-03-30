# IAM Policy

The IAM policy must have permissions for the following actions and resources (at a minimum):
 - AttachNetworkInterface—For permission to attach an ENI to an instance.
 - DescribeNetworkInterface—For fetching the ENI parameters in order to attach an interface to the instance.
  - DetachNetworkInterface—For permission to detach the ENI from the EC2 instance.
  - DescribeInstances—For permission to obtain information on the EC2 instances in the VPC.
  - Wild card (*)—In the Amazon Resource Name (ARN) field use the * as a wild card.
