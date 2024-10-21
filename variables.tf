variable "aws_key_pair" {
    default = "D:/3tier_architecture/april.pem"
  
}

# variable "key_name" {
#   default = april
# }
# variable "instance_type" {
#   default = t2.micro
# }

variable "vpc_cidr" {
    default = "10.0.0.0/16"  
}
variable "vpc_name" {
  default = "myvpc"
}

variable "public_subnet_cidrs" {
 default     = "10.0.1.0/24"
}

# variable "public_subnet_cidrs2" {
#  default     = "10.0.3.0/24"
# }
 
variable "private_subnet_cidrs" {
 default     = "10.0.2.0/24"
}

variable "username" {
  default = "mydbinstance"
}

variable "password" {
  default = "12345678"
}

# variable "endpoint" {
#   default = aws_db_instance.my-db.endpoint
# }
