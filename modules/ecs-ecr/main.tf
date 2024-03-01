# Internet Gateway for the VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = "vpc-0d901141117fda04f"

  tags = {
    Name = "${var.project_name}-${var.environment}-igw"
  }
}

# Subnets
resource "aws_subnet" "subnet_1" {
  vpc_id                  = "vpc-0d901141117fda04f"
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-${var.environment}-subnet-1"
  }
}

resource "aws_subnet" "subnet_2" {
  vpc_id                  = "vpc-0d901141117fda04f"
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-${var.environment}-subnet-2"
  }
}

# Security Group allowing public access to Flask app on port 5000
resource "aws_security_group" "flask_sg" {
  name        = "${var.project_name}-${var.environment}-flask-sg"
  description = "Allow public access to Flask app on port 5000"
  vpc_id      = "vpc-0d901141117fda04f"

  ingress {
    from_port   = 5000
    to_port     = 5000
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
    Name = "${var.project_name}-${var.environment}-flask-sg"
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "cluster" {
  name = "${var.project_name}-${var.environment}-cluster"
}

# ECR Repository
resource "aws_ecr_repository" "repository" {
  name = "${var.project_name}-${var.environment}-ecr"
}

# IAM Role for ECS Task Execution
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

# IAM Role Policy Attachment for ECS Task Execution
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Task Definition with Container Logging
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
      image        = "153295639067.dkr.ecr.us-east-1.amazonaws.com/${var.project_name}-${var.environment}-ecr:latest"
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

# CloudWatch Log Group for ECS Logging
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name = "/ecs/${var.project_name}-${var.environment}"
}

# IAM Role Policy for ECS Logging
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

# ECS Service with Network Configuration
resource "aws_ecs_service" "my_service" {
  name            = "${var.project_name}-${var.environment}-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id]
    assign_public_ip = true
    security_groups = [aws_security_group.flask_sg.id]
  }

  force_new_deployment = true
}
