resource "aws_autoscaling_group" "gamehosts" {
  name                      = "gamehosts"
  max_size                  = 1
  min_size                  = 0
  health_check_grace_period = 300
  default_cooldown          = 300
  health_check_type         = "EC2"
  desired_capacity          = 1
  force_delete              = false
  launch_template {
    name    = aws_launch_template.gamehost.name
    version = "$Latest"
  }
  termination_policies      = ["Default"]
  vpc_zone_identifier       = [aws_subnet.hosts_1.id]

  target_group_arns         = [
    aws_lb_target_group.xtlgame_tcp_80.arn,
    aws_lb_target_group.xtlgame_tcp_8112.arn,
    aws_lb_target_group.xtlgame_tcp_15152.arn
  ]
  
  tag {
    key                 = "Name"
    value               = "xteel-game-server"
    propagate_at_launch = true
  }

  wait_for_capacity_timeout = "0"

  timeouts {
      delete = "5m"
  }
  lifecycle {
    create_before_destroy = true
  }
}