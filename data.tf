data "aws_availability_zones" "availability_zone" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
  state = "available"
}

/* data "aws_ssm_parameter" "instance_ami" {
  name = "/aws/service/canonical/ubuntu/eks/20.04/1.21/stable/20230219/amd64/hvm/ebs-gp2/ami-id"
} */

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu-eks/k8s_1.21/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"] # Canonical
}
