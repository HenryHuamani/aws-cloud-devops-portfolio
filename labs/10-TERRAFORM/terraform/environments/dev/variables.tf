variable "aws_region" {
  description = "AWS region where the infrastructure will be deployed."
  type        = string
  default     = "us-east-2"
}

variable "project_name" {
  description = "Name used to identify the project resources."
  type        = string
  default     = "portfolio-terraform"
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "dev"
}