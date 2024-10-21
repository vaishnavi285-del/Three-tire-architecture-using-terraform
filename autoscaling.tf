#web server load balancer
resource "aws_lb" "myalb-web" {
  name               = "web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.server-sg.id]
  subnets            = [aws_subnet.public_subnet.id]

  enable_deletion_protection = false


}
#target group webserver
resource "aws_lb_target_group" "web_tg" {
  name        = "TG1"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.my-vpc.id
  target_type = "instance"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "web_lb-listner" {
  load_balancer_arn = aws_lb.myalb-web.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

resource "aws_autoscaling_attachment" "web_asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.myasg-web.id
  lb_target_group_arn   = aws_lb_target_group.web_tg.arn
}

# resource "aws_lb_target_group_attachment" "web_asg_attachment" {
#   target_group_arn = aws_lb_target_group.web_tg.arn
#   target_id        = aws_autoscaling_group.myasg-web.instance[0]
#   port             = 80
# }

#load balancer app aerver

resource "aws_lb" "myalb-app" {
  name               = "app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.server-sg.id]
  subnets            = [aws_subnet.public_subnet.id]

  enable_deletion_protection = false

  
}

resource "aws_lb_target_group" "app_tg" {
  name        = "TG2"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = aws_vpc.my-vpc.id
  target_type = "instance"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.myalb-app.arn
  port              = 8080
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

resource "aws_autoscaling_attachment" "app_asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.myasg-app.id
  lb_target_group_arn   = aws_lb_target_group.app_tg.arn
}

# resource "aws_lb_target_group_attachment" "app_asg_attachment" {
#   target_group_arn = aws_lb_target_group.app_tg.arn
#   target_id        = aws_autoscaling_group.myasg-app.id
#   port             = 8080
# }



resource "aws_launch_configuration" "web_launch_config" {
  name          = "web-launch-configuration"
  image_id      = data.aws_ami.myami.id  
  instance_type = "t2.micro"
  security_groups = [aws_security_group.server-sg.id]
  

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y httpd
              sudo systemctl start httpd
              sudo systemctl enable httpd
              echo "Hello this is Web Server" > /var/www/html/index.html
              EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "app_launch_config" {
  name          = "app-launch-configuration"
  image_id      = "ami-0c55b159cbfafe1f0"  
  instance_type = "t2.micro"
  security_groups = [aws_security_group.server-sg.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y java
              EOF

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_autoscaling_group" "myasg-web" {
  launch_configuration = aws_launch_configuration.web_launch_config.id
  min_size             = 1
  max_size             = 2
  desired_capacity     = 1
  vpc_zone_identifier  = [aws_subnet.public_subnet.id]

  
}


resource "aws_autoscaling_group" "myasg-app" {
  launch_configuration = aws_launch_configuration.app_launch_config.id
  min_size             = 1
  max_size             = 2
  desired_capacity     = 1
  vpc_zone_identifier  = [aws_subnet.public_subnet.id]

  
}


resource "aws_sns_topic" "sns_topic" {
  name = "sns_topic"
}

resource "aws_sns_topic_subscription" "sns_topic_sub" {
  topic_arn = aws_sns_topic.sns_topic.id
  protocol  = "email"
  endpoint  = "shindepratham2809@gmail.com"
}

resource "aws_autoscaling_notification" "myasg_notifications" {
  group_names = [aws_autoscaling_group.myasg-app.id,aws_autoscaling_group.myasg-web.id]
  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
  ]
  topic_arn = aws_sns_topic.sns_topic.arn
}

