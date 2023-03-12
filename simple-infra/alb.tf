resource "aws_lb" "alb" {
  name               = "${var.r_prefix}-alb"
  security_groups    = [aws_security_group.sample_sg_alb.id]
  load_balancer_type = "application"

  subnets = [
    "${aws_subnet.sample_public_subnet_1a.id}",
    "${aws_subnet.sample_public_subnet_1c.id}"
  ]

  internal                   = false
  enable_deletion_protection = false

  access_logs {
    bucket = aws_s3_bucket.sample_alb_logs.bucket
  }
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Fixed response content"
      status_code  = "200"
    }
  }
}

resource "aws_lb_listener_rule" "alb_listener_rule" {
  listener_arn = aws_lb_listener.alb_listener.arn
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
  condition {
    path_pattern {
      values = ["*"]
    }
  }
}

resource "aws_lb_target_group" "target_group" {
  name        = "${var.r_prefix}-target-group"
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.sample_vpc.id
  health_check {
    healthy_threshold = 3
    interval          = 30
    path              = "/health_checks"
    protocol          = "HTTP"
    timeout           = 5
  }
}

resource "aws_lb_listener" "redirect_http_to_https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "8080"
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener_rule" "https_redirect" {
  listener_arn = aws_lb_listener.redirect_http_to_https.arn
  priority     = 100
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
  condition {
    host_header {
      values = ["ymnk.fun"]
    }
  }
}