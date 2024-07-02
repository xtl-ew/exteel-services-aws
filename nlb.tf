resource "aws_lb" "xtlgame_nlb" {
  name               = "xtlgame"
  internal           = false
  load_balancer_type = "network"
  subnets            = [ aws_subnet.web_1.id, aws_subnet.web_2.id, aws_subnet.web_3.id ]

  enable_deletion_protection = false

  tags = {
    Name = "xteel-game-nlb"
  }
}

# HTTP FORWARD

resource "aws_lb_target_group" "xtlgame_tcp_80" {
  name     = "xtlgame-80"
  port     = 80
  protocol = "TCP"
  vpc_id   = aws_vpc.web_vpc.id

  health_check {
    timeout             = 5
    interval            = 10
    healthy_threshold   = 2
    unhealthy_threshold = 2
    protocol            = "TCP"
  }
}

resource "aws_lb_listener" "xtlgame_tcp_80" {
  load_balancer_arn = aws_lb.xtlgame_nlb.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.xtlgame_tcp_80.arn
  }
}

# 8112 FORWARD

resource "aws_lb_target_group" "xtlgame_tcp_8112" {
  name     = "xtlgame-8112"
  port     = 8112
  protocol = "TCP"
  vpc_id   = aws_vpc.web_vpc.id

  health_check {
    timeout             = 5
    interval            = 10
    healthy_threshold   = 2
    unhealthy_threshold = 2
    protocol            = "TCP"
  }
}

resource "aws_lb_listener" "xtlgame_tcp_8112" {
  load_balancer_arn = aws_lb.xtlgame_nlb.arn
  port              = "8112"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.xtlgame_tcp_8112.arn
  }
}

# 15152 FORWARD

resource "aws_lb_target_group" "xtlgame_tcp_15152" {
  name     = "xtlgame-15152"
  port     = 15152
  protocol = "TCP"
  vpc_id   = aws_vpc.web_vpc.id

  health_check {
    timeout             = 5
    interval            = 10
    healthy_threshold   = 2
    unhealthy_threshold = 2
    protocol            = "TCP"
  }
}

resource "aws_lb_listener" "xtlgame_tcp_15152" {
  load_balancer_arn = aws_lb.xtlgame_nlb.arn
  port              = "15152"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.xtlgame_tcp_15152.arn
  }
}