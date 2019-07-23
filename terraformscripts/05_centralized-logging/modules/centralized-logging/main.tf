data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "template_file" "centralized-logging_stack" {
  template = "${file("${path.module}/centralized-logging-primary.yaml")}"
  vars 
  {
     DOMAINNAME = "${var.DOMAINNAME}"
    DomainAdminEmail= "${var.DomainAdminEmail}"
    CognitoAdminEmail= "${var.CognitoAdminEmail}"
    ClusterSize= "${var.ClusterSize}"
    DemoTemplate= "${var.DemoTemplate}"
    SpokeAccounts= "${var.SpokeAccounts}"
    DemoVPC= "${var.DemoVPC}"
    DemoSubnet= "${var.DemoSubnet}"
  }

  
}
resource "aws_cloudformation_stack" "centralized-logging" {
  name          = "${var.stack_name}"
  template_body = "${data.template_file.centralized-logging_stack.rendered}"
  parameters = {
    DOMAINNAME = "${var.DOMAINNAME}"
    DomainAdminEmail= "${var.DomainAdminEmail}"
    CognitoAdminEmail= "${var.CognitoAdminEmail}"
    ClusterSize= "${var.ClusterSize}"
    DemoTemplate= "${var.DemoTemplate}"
    SpokeAccounts= "${var.SpokeAccounts}"
    DemoVPC= "${var.DemoVPC}"
    DemoSubnet= "${var.DemoSubnet}"
  }
  capabilities=["CAPABILITY_IAM"]
  tags = "${merge(map("Name", format("%s", var.stack_name)), var.tags)}"

}   