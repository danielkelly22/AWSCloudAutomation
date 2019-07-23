data "template_file" "cloudformation_sns_stack" {
  template = "${file("${path.module}/email-sns-stack.json")}"
  vars {
    display_name  = "${var.display_name}"
    subscriptions = "${join("," , formatlist("{ \"Endpoint\": \"%s\", \"Protocol\": \"%s\"  }", var.subscriptions, "email"))}"
  }
}
resource "aws_cloudformation_stack" "sns_topic" {
  name          = "${var.stack_name}"
  template_body = "${data.template_file.cloudformation_sns_stack.rendered}"
  tags = "${merge(map("Name", format("%s", var.stack_name)), var.tags)}"

}