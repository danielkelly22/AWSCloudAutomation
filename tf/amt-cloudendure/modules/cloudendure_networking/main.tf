resource "aws_security_group" "cloudendure_replication_servers" {
  vpc_id = var.cloudendure_replication_vpc_id

  name = "amt-${var.environment_affix}-servers"
  description = "amt-${var.environment_affix}-servers"

  ingress {
    description = "https ingress"
    self        = false
    protocol    = "TCP"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "cloudendure replication ingress"
    self        = false
    protocol    = "TCP"
    from_port   = 1500
    to_port     = 1500
    cidr_blocks = ["0.0.0.0/0"]
  }

//  egress {
//    description = "Self-egress."
//    self        = true
//    protocol    = -1
//    from_port   = 0
//    to_port     = 0
//  }

  tags = merge(var.tags, {
    Name = "amt-${var.environment_affix}-servers"
  })
}
