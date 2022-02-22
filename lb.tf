resource "aws_lb" "aisk_prd" {
  name                       = "aisk-prd-alb"
  load_balancer_type         = "application"
  internal                   = false
  idle_timeout               = 60
  enable_deletion_protection = true

  subnets = [
    aws_subnet.public_0.id,
    aws_subnet.public_1.id,
  ]

  access_logs {
    bucket  = aws_s3_bucket.alb_log.id
    enabled = true
  }

  security_groups = [
    module.http_sg.security_group_id,
    module.https_sg.security_group_id,
    module.http_redirect_sg.security_group_id,
  ]
}

resource "aws_s3_bucket_lifecycle_configuration" "alb_log" {
  bucket = aws_s3_bucket.alb_log.id

  rule {
    id = "180日間保存する"
    status = "Enabled"
    expiration {
      days = 180
    }
  }

}
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.aisk_prd.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port = "443"
      protocol = "HTTPS"
      status_code  = "HTTP_301"
    }
  }
}
resource "aws_lb_listener" "https" {
  load_balancer_arn=aws_lb.aisk_prd.arn
  port="443"
  protocol="HTTPS"
  certificate_arn=aws_acm_certificate.aisk.arn
  ssl_policy="ELBSecurityPolicy-2016-08"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type ="text/plain"
      message_body = "これはhttpsです"
      status_code ="200"
    }
  }
}

resource "aws_s3_bucket" "alb_log" {
  bucket = "aisk-prd-alb-log"

  tags = {
    Name = "aisk-prd_alb_log_repository"
  }
}

resource "aws_s3_bucket_policy" "alb_log" {
  bucket = aws_s3_bucket.alb_log.id
  policy = data.aws_iam_policy_document.alb_log.json
}

data "aws_iam_policy_document" "alb_log" {
  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.alb_log.id}/*"]

    principals {
      type        = "AWS"
      identifiers = ["582318560864"]
    }
  }
}
resource "aws_lb_target_group" "aisk-prd-app-ecs-group" {
  name                 = "aisk-prd-app-ecs-group"
  target_type          = "ip"
  vpc_id               = aws_vpc.aisk_prd.id
  port                 = 80
  protocol             = "HTTP"
  deregistration_delay = 300

  health_check {
    path                = "/"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = 200
    port                = "traffic-port"
    protocol            = "HTTP"
  }

  depends_on = [aws_lb.aisk_prd]
}

resource "aws_lb_listener_rule" "aisk-prd-lb-listener-rule" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.aisk-prd-app-ecs-group.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}
