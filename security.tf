#S3 Public Access Policy
data "aws_iam_policy_document" "private_bucket" {
  statement {
    sid = "Public View"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "s3:*"
    ]
    resources = [
      aws_s3_bucket.private_bucket.arn, "${aws_s3_bucket.private_bucket.arn}/*"
    ]
  }
}

#Define Default Security Group
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id

  ingress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
