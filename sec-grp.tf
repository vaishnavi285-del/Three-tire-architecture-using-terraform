resource "aws_security_group" "alb-sg" {
    name = "alb-sg"
    description = "ALB security group"
    vpc_id = aws_vpc.my-vpc.id

    ingress {
        from_port        = 22
        to_port          = 22
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
    }

    ingress {
        from_port        = 80
        to_port          = 80
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
    }

    ingress {
        from_port        = 443
        to_port          = 443
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
    }

    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
    }
  
}

resource "aws_security_group" "server-sg" {
    name = "server-sg"
    description = "server security group allowing traffic only from application load balancer"
    vpc_id = aws_vpc.my-vpc.id

    ingress {
        from_port        = 22
        to_port          = 22
        protocol         = "tcp"
        security_groups  = ["${aws_security_group.alb-sg.id}"]
    }

    ingress {
        from_port        = 80
        to_port          = 80
        protocol         = "tcp"
        security_groups  = ["${aws_security_group.alb-sg.id}"]
    }

    ingress {
        from_port        = 443
        to_port          = 443
        protocol         = "tcp"
        security_groups  = ["${aws_security_group.alb-sg.id}"]
    }

    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
    }
  
}

resource "aws_security_group" "DB-sg" {
    name = "DB-sg"
    description = "server security group for database server"
    vpc_id = aws_vpc.my-vpc.id

    ingress {
        description      = "mysql"
        from_port        = 3306
        to_port          = 3306
        protocol         = "tcp"
        cidr_blocks      = [aws_subnet.private_subnets.cidr_block]
    }

    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
    }
  
}
