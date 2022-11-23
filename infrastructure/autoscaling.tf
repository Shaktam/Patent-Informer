resource "aws_launch_template" "webserver" {

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 20
    }
  }

  iam_instance_profile {
    name = "LabInstanceProfile"
  }

  image_id = "ami-094125af156557ca2"
  instance_type = "t3.micro"
  key_name = "vockey"
  vpc_security_group_ids = [aws_security_group.security_group.id]
 # user_data = filebase64("script/userdata.sh")
}

resource "aws_autoscaling_group" "webserver" {
  vpc_zone_identifier       = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id]
  desired_capacity   = 2
  max_size           = 3
  min_size           = 1

  launch_template {
    id      = aws_launch_template.webserver.id
    version = "$Latest"
  }
  depends_on = [
    aws_nat_gateway.nat_gw
  ]
  target_group_arns = [aws_lb_target_group.webserver_lb_tg.arn]
}
