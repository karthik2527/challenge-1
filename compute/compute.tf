data "aws_ami" "al2ami" {
  most_recent      = true
  owners           = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_launch_template" "webtier-template" {
  name = "webtier-template"

  
  instance_type = var.size_of_ec2
  vpc_security_group_ids = [var.instance_sg]
  image_id = data.aws_ami.al2ami.image_id
  user_data = filebase64("${path.module}/userdata.sh")

  tags = {
    Name = "web-tier-instance"
  }
}

resource "aws_lb" "webtier-nlb" {
  name               = "web-tier-nlb"
  load_balancer_type = "network"

  subnet_mapping {
    subnet_id     = var.public_subnet
    allocation_id = var.nlb_eip
  }
}

resource "aws_lb_target_group" "webtier-nlb-tg" {
  name        = "web-tier-nlb-tg"
  port        = 443
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.webapp_vpc
  preserve_client_ip = false
}

resource "aws_lb_listener" "webtier-nlb-listener" {
  load_balancer_arn = aws_lb.webtier-nlb.arn
  port              = "443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webtier-nlb-tg.arn
  }
}

resource "aws_autoscaling_group" "webtier-asg" {
  name = "webtier-asg"
  max_size = 3
  min_size = 2
  desired_capacity = 2
  vpc_zone_identifier = [var.private_subnet1, var.private_subnet2]
  target_group_arns = [aws_lb_target_group.webtier-nlb-tg.arn]

  launch_template {
    id      = aws_launch_template.webtier-template.id
    version = "$Latest"
  }

  tag {
    key = "Name"
    value = "web-tier-instance"
    propagate_at_launch = true
  }
}
