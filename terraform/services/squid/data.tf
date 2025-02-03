data "aws_vpc" "selected" {
  filter {
    name   = "tag:tier"
    values = [var.env]
  }
  filter {
    name   = "tag:environment"
    values = [var.env]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "tag:tier"
    values = [var.env]
  }

  tags = {
    subnet_type = "public"
  }
}
