
resource "aws_security_group" "lb_sg" {
  name        = "allow_http"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.patent_vpc.id

  ingress {
    description      = "http"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_http"
  }
}

resource "aws_lb" "patent_lb" {
  name               = "patent-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]
}

resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.patent_lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.webserver_lb_tg.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group" "webserver_lb_tg" {
  name     = "http"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.patent_vpc.id

  health_check {
    port     = 80
    protocol = "HTTP"
  }
}

output "load_balancer_dns" {
  value       = aws_lb.patent_lb.dns_name
  description = "Dns name of lb"
}