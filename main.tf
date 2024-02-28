provider "aws" {
  region = var.region
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
