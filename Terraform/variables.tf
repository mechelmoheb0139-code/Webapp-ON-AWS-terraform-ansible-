
variable "region" {
  description = "AWS Region"
  type        = string
}

variable "vpc_id" {
  description = "Existing VPC ID"
  type        = string
  default     = "vpc-0e5815b97f142c6e6"
}

variable "my_ip_cidr" {
  description = "Your public IP address for SSH"
  type        = string
}

variable "public_subnet_ids" {
  description = "Existing public subnet IDs"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Existing private subnet IDs"
  type        = list(string)
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "enterprise-app"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  type    = string
  default = "app-key"
}
