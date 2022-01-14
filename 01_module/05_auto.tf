// web 인스턴스 ami 생성
resource "aws_ami_from_instance" "explorer_ami" {

  name               = "${var.name}-ami"
  source_instance_id = aws_instance.explorer_web.id
  depends_on = [
    aws_instance.explorer_web
  ]
}
// 시작구성 설정
resource "aws_launch_configuration" "explorer_lacf" {

  name                 = "${var.name}-web"
  image_id             = aws_ami_from_instance.explorer_ami.id
  instance_type        = var.instance_t2
  iam_instance_profile = var.lacf_iam
  security_groups      = [aws_security_group.explorer_websg.id]
  key_name             = var.key
  
  lifecycle {
    create_before_destroy = true
  }
}
// 배치 설정
resource "aws_placement_group" "explorer_pg" {
  name     = "${var.name}-pg"
  strategy = var.pg_strategy

}
//오토스케일링 그룹 설정
resource "aws_autoscaling_group" "explorer_autogroup" {
 # count          = "${length(var.public_s)}"
  name                      = "${var.name}-autogroup"
  min_size                  = var.auto_min
  max_size                  = var.auto_max
  health_check_grace_period = var.auto_healthcheck_grace_period
  //health_check_type         = var.auto_healthcheck_type
  desired_capacity          = var.auto_desired_capacity
  force_delete              = var.auto_force_delete
  launch_configuration      = aws_launch_configuration.explorer_lacf.name
  vpc_zone_identifier       = [aws_subnet.explorer_pri[0].id,aws_subnet.explorer_pri[1].id]

}
//오토스케일링을 lb와 연결
resource "aws_autoscaling_attachment" "explorer_autoattach" {

  autoscaling_group_name = aws_autoscaling_group.explorer_autogroup.id
  alb_target_group_arn   = aws_lb_target_group.explorer_lbtg.arn

}



##was##############################################################
//was ami 생성
resource "aws_ami_from_instance" "explorer_was_ami" {

  name               = "${var.name}-was-ami"
  source_instance_id = aws_instance.explorer_wasa.id
  depends_on = [
    aws_instance.explorer_wasa
  ]
}

//was 시작구성 설정
resource "aws_launch_configuration" "explorer_was_lacf" {

  name                 = "${var.name}-was"
  image_id             = aws_ami_from_instance.explorer_was_ami.id
  instance_type        = var.instance
  iam_instance_profile = var.lacf_iam
  security_groups      = [aws_security_group.explorer_wassg.id]
  key_name             = var.key
  
  lifecycle {
    create_before_destroy = true
  }
}

//was 오토스케일링 설정
resource "aws_autoscaling_group" "explorer_was_autogroup" {

  name                      = "${var.name}-was-autogroup"
  min_size                  = var.auto_min
  max_size                  = var.auto_max
  health_check_grace_period = var.auto_healthcheck_grace_period
  //health_check_type         = var.auto_healthcheck_type
  desired_capacity          = var.auto_desired_capacity
  force_delete              = var.auto_force_delete
  launch_configuration      = aws_launch_configuration.explorer_was_lacf.name
  vpc_zone_identifier       = [aws_subnet.explorer_pri[0].id,aws_subnet.explorer_pri[1].id]

 
}

// 오토스케일링 lb 연결
resource "aws_autoscaling_attachment" "explorer_was_autoattach" {

  autoscaling_group_name = aws_autoscaling_group.explorer_was_autogroup.id
  alb_target_group_arn   = aws_lb_target_group.explorer_nlbtg.arn

}
