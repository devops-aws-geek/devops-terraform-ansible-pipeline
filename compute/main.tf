# --- compute/main.tf ---

data "aws_ami" "linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

resource "aws_launch_template" "web-batch891" {
  name_prefix            = "web-batch891"
  image_id               = data.aws_ami.linux.id
  key_name               = "batch-910"
  instance_type          = var.web_instance_type
  vpc_security_group_ids = [var.web_sg]
  user_data              = filebase64("install_apache.sh")

  tags = {
    Name = "web-batch891"
  }
}

resource "aws_autoscaling_group" "web-batch891" {
  name                = "web-batch891"
  vpc_zone_identifier = tolist(var.public_subnet)
  min_size            = 1
  max_size            = 3
  desired_capacity    = 1

  launch_template {
    id      = aws_launch_template.web-batch891.id
    version = "$Latest"
  }
}

