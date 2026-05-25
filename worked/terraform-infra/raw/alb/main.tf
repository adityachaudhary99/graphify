# Application Load Balancers
# ALB requires at least 2 subnets in different AZs, so we use all public subnets
resource "aws_lb" "main" {
  for_each = toset(var.environments)
  
  name               = "${var.project}-${each.key}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_ids[each.key]]
  subnets            = values(var.public_subnet_ids)
  
  enable_deletion_protection       = each.key == "prod" ? true : false
  enable_http2                     = true
  enable_cross_zone_load_balancing = true
  
  tags = {
    Name        = "${var.project}-${each.key}-alb"
    Environment = each.key
  }
}

# Target Groups
resource "aws_lb_target_group" "main" {
  for_each = toset(var.environments)
  
  name        = "${var.project}-${each.key}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  
  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200"
  }
  
  deregistration_delay = 30
  
  tags = {
    Name        = "${var.project}-${each.key}-tg"
    Environment = each.key
  }
}

# HTTP Listeners
resource "aws_lb_listener" "http" {
  for_each = toset(var.environments)
  
  load_balancer_arn = aws_lb.main[each.key].arn
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main[each.key].arn
  }
  
  tags = {
    Environment = each.key
  }
}
