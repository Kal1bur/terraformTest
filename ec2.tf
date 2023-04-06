resource "aws_instance" "main" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  key_name               = "robt-key"
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_default_security_group.default.id]
  tags = {
    Name = "${var.default_tags.env}-EC2"
  }
  user_data = base64encode(file("C:/Users/newyo_w4uaj88/Desktop/terraform/user.sh"))
}

output "ec2_ssh_command" {
  value = "ssh -i robt-key.pem ubuntu@ec2-${replace(aws_instance.main.public_ip, ".", "-")}.compute-1.amazonaws.com"
}
