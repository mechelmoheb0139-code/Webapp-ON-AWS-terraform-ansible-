
# =====================================
# ALB Outputs
# =====================================

output "alb_dns_name" {
  description = "Application Load Balancer DNS"
  value       = aws_lb.app_alb.dns_name
}

output "alb_zone_id" {
  description = "Application Load Balancer Hosted Zone ID"
  value       = aws_lb.app_alb.zone_id
}

# =====================================
# App Server Outputs
# =====================================

output "app_instance_id" {
  value = aws_instance.app.id
}

output "app_public_ip" {
  value = aws_instance.app.public_ip
}

output "app_private_ip" {
  value = aws_instance.app.private_ip
}

# =====================================
# Backend Outputs
# =====================================

output "mariadb_private_ip" {
  value = aws_instance.mariadb.private_ip
}

output "rabbitmq_private_ip" {
  value = aws_instance.rabbitmq.private_ip
}

output "memcached_private_ip" {
  value = aws_instance.memcached.private_ip
}

# =====================================
# Backend Instance IDs
# =====================================

output "mariadb_instance_id" {
  value = aws_instance.mariadb.id
}

output "rabbitmq_instance_id" {
  value = aws_instance.rabbitmq.id
}

output "memcached_instance_id" {
  value = aws_instance.memcached.id
}

