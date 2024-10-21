data "aws_ami" "myami" {
    most_recent = true
    owners = ["amazon"]
    filter {
      name =  "name"
      values = ["amzn2-ami-hvm-*"]
    }
  
}
data "aws_availability_zones" "available" {
  state = "available"
}
