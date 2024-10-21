terraform {
  backend "s3" {
    bucket = "proj1-backend-state"
    key = "value"
    region = "us-east-1"
    dynamodb_table = "dev_application_locks"
    encrypt = true
    
  }
}


provider "aws" {
    region = "us-east-1"
}

resource "aws_vpc" "my-vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = var.vpc_name
  }
}

resource "aws_internet_gateway" "IG" {
  vpc_id = aws_vpc.my-vpc.id
  tags = {
    Name = "IGfor${var.vpc_name}"
  }
}

resource "aws_subnet" "public_subnet" {
 vpc_id     = aws_vpc.my-vpc.id
 cidr_block = var.public_subnet_cidrs
 map_public_ip_on_launch = true
 tags = {
   Name = "Public Subnet"
 }
}

# resource "aws_subnet" "public_subnet2" {
#  vpc_id     = aws_vpc.my-vpc.id
#  cidr_block = var.public_subnet_cidrs2
#  map_public_ip_on_launch = true
#  tags = {
#    Name = "Public Subnet2"
#  }
# }

resource "aws_route_table" "PubRT" {
  vpc_id = aws_vpc.my-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IG.id
  }
}

resource "aws_route_table_association" "PubRTAsso" {
    route_table_id = aws_route_table.PubRT.id
    subnet_id = aws_subnet.public_subnet.id
}



resource "aws_subnet" "private_subnets" {
 vpc_id     = aws_vpc.my-vpc.id
 cidr_block = var.private_subnet_cidrs
 availability_zone = data.aws_availability_zones.available.names[count.index]
 
 tags = {
   Name = "Private Subnet"
 }
}

resource "aws_eip" "eip_nat" {
  vpc = true
}

resource "aws_nat_gateway" "natGW" {
  subnet_id = aws_subnet.public_subnet.id
  allocation_id = aws_eip.eip_nat.id
}

resource "aws_route_table" "PriRT" {
  vpc_id = aws_vpc.my-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natGW.id
  }
}

resource "aws_route_table_association" "PriRTAsso" {
    route_table_id = aws_route_table.PriRT.id
    subnet_id = aws_subnet.private_subnets.id

}

# resource "aws_instance" "webserver" {
#     ami = data.aws_ami.myami.id
#     instance_type = "t2.micro"
#     key_name = "april.pem"
#     subnet_id = aws_subnet.public_subnets.id
#     security_groups = [aws_security_group.server-sg.id]

#     connection {
#       host = self.public_ip
#       user = "ec2-user"
#       type = "ssh"
#       private_key = file(var.aws_key_pair)
      
#     }

#     provisioner "remote-exec" {
#         inline = [ 
#             "sudo yum install httpd -y",
#             "sudo service httpd start",
#             "echo hi this is webserver created in terraform |sudo tee /var/www/html/index.html"
#          ]
      
#     }

# }

# resource "aws_instance" "appserver" {
#     ami = data.aws_ami.myami.id
#     instance_type = "t2.micro"
#     key_name = "april.pem"
#     subnet_id = aws_subnet.public_subnets.id
#     security_groups = [aws_security_group.server-sg.id]

#     connection {
#       host = self.public_ip
#       user = "ec2-user"
#       type = "ssh"
#       private_key = file(var.aws_key_pair)
      
#     }

#     provisioner "remote-exec" {
#         inline = [ 
#             "sudo yum install httpd -y",
#             "sudo service httpd start",
#             "echo hi this is webserver created in terraform |sudo tee /var/www/html/index.html"
#          ]
      
#     }

# }

# resource "aws_instance" "dbserver" {
#     ami = data.aws_ami.myami.id
#     instance_type = "t2.micro"
#     key_name = "april"
#     subnet_id = aws_subnet.private_subnets.id
#     security_groups = [aws_security_group.DB-sg.id]


#     connection {
#       host = self.public_ip
#       user = "ec2-user"
#       type = "ssh"
#       private_key = file(var.aws_key_pair)
      
#     }

#     provisioner "remote-exec" {
#         inline = [
#             "sudo yum update -y", 
#             "sudo yum install mysql -y",
#             # "mysql -h ${aws_db_instance.my-db.endpoint} -P 3306 -u ${var.username} -p ${var.password}"
#             # "sudo service httpd start",
#             # "echo hi this is webserver created in terraform |sudo tee /var/www/html/index.html"
#          ]
      
#     }

# }





