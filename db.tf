resource "aws_db_subnet_group" "sub-group" {
  name       = "main-subnet-group"
  subnet_ids = ["${aws_subnet.private_subnets.*.id}"]

}

resource "aws_db_instance" "my-db" {
  db_name              = "ethans"
  allocated_storage    = 10
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = var.username
  password             = var.password
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.sub-group.name
  vpc_security_group_ids = [aws_security_group.DB-sg.id]
}

