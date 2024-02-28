resource "aws_ecs_cluster" "cluster" {
  name = "${var.project_name}-${var.environment}-cluster"
}

resource "aws_ecr_repository" "repository" {
  name = "${var.project_name}-${var.environment}-ecr"
}

#part 1:  Create the IAM role that ECS cluster needs
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.project_name}-${var.environment}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      },
    ]
  })
}


resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}




# part 2: Task definition
resource "aws_ecs_task_definition" "app" {
  family                   = "myapp-prod"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([
    {
      name         = "myapp-prod"
      image        = "153295639067.dkr.ecr.us-east-1.amazonaws.com/flask_deployment-prod-ecr:latest"
      essential    = true
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
        }
      ],
      logging = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = "/ecs/${var.project_name}-${var.environment}",
          awslogs-region        = "us-east-1",
          awslogs-stream-prefix = "ecs"
        }
      },
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:5000/health || exit 1"],
        interval    = 30,
        timeout     = 10,
        retries     = 3,
        startPeriod = 30
      }
    }
  ])
}

# part 2: resource log group
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name = "/ecs/${var.project_name}-${var.environment}"
}

# part 3: adding logging to role
resource "aws_iam_role_policy" "ecs_logging" {
  name = "${var.project_name}-${var.environment}-ecs-logging"
  role = aws_iam_role.ecs_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:log-group:/ecs/${var.project_name}-${var.environment}:*",
        Effect = "Allow",
      },
    ],
  })
}

# part 4: network configuration
# ECS Service with network configuration
resource "aws_ecs_service" "my_service" {
  name            = "${var.project_name}-${var.environment}-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = ["subnet-0a9a486148479e71b", "subnet-0addfd0ca5eb1753a"] # Replace with your actual subnet IDs
    assign_public_ip = true
    security_groups = ["sg-01d73761ebd823067"] # Replace with your actual security group ID
  }

  # Ensure the service uses the latest version of the task definition
  force_new_deployment = true
}
