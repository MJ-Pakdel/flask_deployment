provider "aws" {
  region = var.region
}

terraform {
  required_version = "~> 1.0"

  backend "s3" {
    bucket         = "mjpakdel-flask-deployment"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    # Optional: Enable if you decide to use state locking in the future
    # dynamodb_table = "your-terraform-lock-table"
  }
}


#module "ecs_ecr_test" {
#  source       = "./modules/ecs-ecr"
#  environment  = "test"
#  project_name = var.project_name
#}

module "ecs_ecr_prod" {
  source       = "./modules/ecs-ecr"
  environment  = "prod"
  project_name = var.project_name
}
