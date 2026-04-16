# Defines compute-layer resources (security group, launch template, and autoscaling group).

resource "aws_security_group" "asg" {
  name        = "${var.name_prefix}-asg-sg"
  description = "Security group for ASG instances."
  vpc_id      = var.vpc_id

  egress {
    description = "Allow outbound HTTPS for updates and package downloads."
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-asg-sg" })
}

data "aws_ssm_parameter" "al2023_ami" {
  count = var.ami_id == "" ? 1 : 0
  name  = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64"
}

locals {
  launch_template_ami_id = var.ami_id != "" ? var.ami_id : data.aws_ssm_parameter.al2023_ami[0].value
}

resource "aws_launch_template" "this" {
  name_prefix   = "${var.name_prefix}-lt-"
  image_id      = local.launch_template_ami_id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.asg.id]

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
}

resource "aws_autoscaling_group" "this" {
  name                = "${var.name_prefix}-asg"
  min_size            = var.asg_min_size
  max_size            = var.asg_max_size
  desired_capacity    = var.asg_desired_capacity
  vpc_zone_identifier = var.private_subnet_ids

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.name_prefix}-asg-instance"
    propagate_at_launch = true
  }
}
