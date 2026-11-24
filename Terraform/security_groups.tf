
# =====================================
# ALB Security Group
# =====================================

resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Allow HTTP and HTTPS from internet"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg"
  }
}

# =====================================
# Application Security Group
# =====================================

resource "aws_security_group" "app_sg" {
  name        = "app-sg"
  description = "Allow traffic from ALB and SSH from my IP"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "app-sg"
  }
}

# =====================================
# MariaDB Security Group
# =====================================

resource "aws_security_group" "mariadb_sg" {
  name        = "mariadb-sg"
  description = "Allow MySQL traffic from App Server"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MariaDB from App"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  ingress {
    description     = "SSH from Ansible Control Node"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mariadb-sg"
  }
}

# =====================================
# RabbitMQ Security Group
# =====================================

resource "aws_security_group" "rabbitmq_sg" {
  name        = "rabbitmq-sg"
  description = "Allow RabbitMQ from App Server"
  vpc_id      = var.vpc_id

  ingress {
    description     = "RabbitMQ AMQP from App"
    from_port       = 5672
    to_port         = 5672
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }
  ingress {
    description     = "SSH from Ansible Control Node"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rabbitmq-sg"
  }
}

# =====================================
# Memcached Security Group
# =====================================

resource "aws_security_group" "memcached_sg" {
  name        = "memcached-sg"
  description = "Allow Memcached from App Server"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Memcached from App"
    from_port       = 11211
    to_port         = 11211
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }
  ingress {
    description     = "SSH from Ansible Control Node"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "memcached-sg"
  }
}

