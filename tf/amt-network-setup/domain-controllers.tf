resource "aws_instance" "dc_a" {
  provider          = aws.shared
  ami               = var.dc_ami_id
  instance_type     = var.dc_instance_size
  availability_zone = "us-east-1a"
  subnet_id         = var.dc_subnets.subnet_a_id
  key_name          = "sharedvpckeys"

  lifecycle = {
    ignore = [iam_instance_profile]
  }

  tags = merge(module.shared_tags.tags, {
    Name = "amt-sharedservices-dc-a"
  })
}

resource "aws_instance" "dc_b" {
  provider          = aws.shared
  ami               = var.dc_ami_id
  instance_type     = var.dc_instance_size
  availability_zone = "us-east-1b"
  subnet_id         = var.dc_subnets.subnet_b_id
  key_name          = "sharedvpckeys"

  lifecycle = {
    ignore = [iam_instance_profile]
  }

  tags = merge(module.shared_tags.tags, {
    Name = "amt-sharedservices-dc-b"
  })
}
