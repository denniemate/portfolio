//alb 생성
resource "aws_lb" "explorer_lb" {
  name               = "${var.name}-alb"
  internal           = var.load_internal
  load_balancer_type = var.load_type
  security_groups    = [aws_security_group.explorer_albsg.id]
  subnets            = [aws_subnet.explorer_pub[0].id,aws_subnet.explorer_pub[1].id]
  

  tags = {
    Name = "${var.name}-alb"
  }
}
//alb 타겟그룹 설정
resource "aws_lb_target_group" "explorer_lbtg" {
  name     = "${var.name}-lbtg"
  port     = var.http_port
  protocol = var.prot_HTTP
  vpc_id   = aws_vpc.explorer_vpc.id
  health_check {
    enabled             = var.health_enabled
    healthy_threshold   = var.health_threshold
    interval            = var.health_interval
    matcher             = var.health_matcher
    path                = var.health_path
    port                = var.health_prot
    protocol            = var.prot_HTTP
    timeout             = var.health_timeout
    unhealthy_threshold = var.health_unhealthy_threshold

  }
}
//alb 리스너 설정
resource "aws_lb_listener" "explorer_lblist" {
  load_balancer_arn = aws_lb.explorer_lb.arn
  port              = var.http_port
  protocol          = var.prot_HTTP

  default_action {
    type             = var.lb_listner_action_type
    target_group_arn = aws_lb_target_group.explorer_lbtg.arn

  }
}

###was
//nlb 생성
resource "aws_lb" "explorer_nlb" {
    name                = "explorer-nlb"
    internal            = true
    load_balancer_type  = "network"
    subnets             = [aws_subnet.explorer_pri[0].id,aws_subnet.explorer_pri[1].id]
    
    tags = {
        Name = "explorer-nlb"
    }


}
//nlb 타겟그룹 설정
resource "aws_lb_target_group" "explorer_nlbtg" {
    name            = "explorer-nlbtg"
    port            = 8080
    protocol        = "TCP"
    vpc_id          = aws_vpc.explorer_vpc.id 
    health_check {
      enabled               = true
      healthy_threshold     = 2
      interval              = 10
      port                  = "traffic-port"
      protocol              = "TCP"
      unhealthy_threshold   = 2
      
    }   
}
//nlb 리스너 설정
resource "aws_lb_listener" "explorer_nlblist" {
    load_balancer_arn       = aws_lb.explorer_nlb.arn
    port                    = 80
    protocol                = "TCP"

    default_action{
        type                     = "forward"
        target_group_arn    = aws_lb_target_group.explorer_nlbtg.arn  
        
    } 
}

