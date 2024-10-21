output "web_alb_dns_name" {
  value = aws_lb.myalb-web.dns_name
}
output "app_alb_dns_name" {
  value = aws_lb.myalb-app.dns_name
}
output "db_instance_endpoint" {
  value = aws_db_instance.my-db.endpoint
}
# output "db-instance-pub-ip" {
#   value = aws_instance.dbserver.public_ip
  
# }
