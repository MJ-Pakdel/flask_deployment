variable "region" {
  description = "AWS region to deploy resources"
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name to create resources"
  type        = string
}

variable "environments" {
  description = "List of environments"
  type        = list(string)
  default     = ["test", "prod"]
}