
# =====================================
# Common Configuration
# =====================================

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

locals {
  ami_id = data.aws_ami.ubuntu.id
}

# =====================================
# 1. Application Server
# =====================================

resource "aws_instance" "app" {
  ami                    = local.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  key_name               = "app-key"

  associate_public_ip_address = true


  tags = {
    Name = "${var.project_name}-app"
    Role = "Application"
  }
}

# =====================================
# 2. MariaDB Server
# =====================================

resource "aws_instance" "mariadb" {
  ami                    = local.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.mariadb_sg.id]
  key_name               = "app-key"

  associate_public_ip_address = false

  tags = {
    Name = "${var.project_name}-mariadb"
    Role = "Database"
  }
}

# =====================================
# 3. RabbitMQ Server
# =====================================

resource "aws_instance" "rabbitmq" {
  ami                    = local.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.rabbitmq_sg.id]
  key_name               = "app-key"

  associate_public_ip_address = false


  tags = {
    Name = "${var.project_name}-rabbitmq"
    Role = "MessageBroker"
  }
}

# =====================================
# 4. Memcached Server
# =====================================

resource "aws_instance" "memcached" {
  ami                    = local.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.memcached_sg.id]
  key_name               = "app-key"

  associate_public_ip_address = false


  tags = {
    Name = "${var.project_name}-memcached"
    Role = "Cache"
  }
}

