module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name = "my-test-vpc"
  cidr = "192.168.0.0/16"
  azs             = ["eu-west-2a", "eu-west-2b"]
  private_subnets = ["192.168.10.0/24", "192.168.20.0/24"]
  public_subnets  = ["192.168.30.0/24", "192.168.40.0/24"]
  enable_nat_gateway = true
  enable_vpn_gateway = false
  tags = {
    Terraform = "true"
    Environment = "test"
  }
  map_public_ip_on_launch = true
}
module "asg" {
  source = "terraform-aws-modules/autoscaling/aws"
  name = "test-app"
  image_id        = "ami-08b064b1296caf3b2"
  instance_type   = "t2.nano"
  security_groups = [aws_security_group.test_app.id]
  user_data = filebase64("install.sh")
  vpc_zone_identifier       = module.vpc.private_subnets
  health_check_type         = "EC2"
  min_size                  = 2
  max_size                  = 2
  desired_capacity          = 2
  wait_for_capacity_timeout = 0
  target_group_arns = [aws_lb_target_group.http.arn]
  depends_on = [ module.vpc ]
}

resource "aws_security_group" "test_app" {
  name        = "test-app-sg"
  description = "Allow 80 port inbound traffic"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group_rule" "allow_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  # cidr_blocks       = ["0.0.0.0/0"]
  source_security_group_id = aws_security_group.test_app_lb.id
  security_group_id = aws_security_group.test_app.id
}

resource "aws_security_group_rule" "allow_mysql_outbound" {
  type              = "egress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = [module.vpc.vpc_cidr_block]
  security_group_id = aws_security_group.test_app.id
}

resource "aws_security_group_rule" "allow_https_outbound" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.test_app.id
}

resource "aws_security_group" "test_app_lb" {
  name        = "test-app-sg-lb"
  description = "Allow 80 port inbound traffic"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group_rule" "allow_http_lb" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.test_app_lb.id
}

resource "aws_security_group_rule" "allow_http_outbound_lb" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.test_app_lb.id
}


resource "aws_lb" "test_app" {
  name               = "test-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.test_app_lb.id]
  subnets            = toset(module.vpc.public_subnets)
  enable_deletion_protection = false
  tags = {
    Environment = "test"
  }
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.test_app.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.http.arn
  }
}

resource "aws_lb_target_group" "http" {
  name     = "test-app-asg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
}

