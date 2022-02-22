resource "aws_ecs_cluster" "aisk-prd" {
  name = "aisk-prd"
}

resource "aws_ecs_task_definition" "aisk-prd-app" {
  family                   = "aisk-prd-app"
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  container_definitions    = file("${path.module}/prd_app_container_definitions.json")

  volume {
    name      = "sockets"
    host_path = "/app/tmp/sockets"
  }
}

resource "aws_ecs_service" "aisk-prd-app" {
  name                              = "aisk-prd-app-ecs-service"
  cluster                           = aws_ecs_cluster.aisk-prd.arn
  task_definition                   = aws_ecs_task_definition.aisk-prd-app.arn
  desired_count                     = 2
  launch_type                       = "FARGATE"
  platform_version                  = "1.3.0"
  health_check_grace_period_seconds = 60

  network_configuration {
    assign_public_ip = false
    security_groups  = [module.nginx_sg.security_group_id]

    subnets = [
      aws_subnet.private_0.id,
      aws_subnet.private_1.id,
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.aisk-prd-app-ecs-group.arn
    container_name   = "aisk-prd-app"
    container_port   = 80
  }

  lifecycle {
    ignore_changes = [task_definition]
  }
}

//ECRの設定
resource "aws_ecr_repository" "aisk-rails-api" {
  name = "rails-api"
}

resource "aws_ecr_repository" "aisk-nginx" {
  name = "aisk-nginx"
}

resource "aws_ecr_lifecycle_policy" "aisk-rails-api" {
  repository = aws_ecr_repository.aisk-rails-api.name

  policy = <<EOF
  {
    "rules": [
      {
        "rulePriority": 1,
        "description": "Keep last 30 release tagged images",
        "selection": {
          "tagStatus": "tagged",
          "tagPrefixList": ["release"],
          "countType": "imageCountMoreThan",
          "countNumber": 30
        },
        "action": {
          "type": "expire"
        }
      }
    ]
  }
  EOF
}

resource "aws_ecr_lifecycle_policy" "aisk-nginx" {
  repository = aws_ecr_repository.aisk-nginx.name

  policy = <<EOF
  {
    "rules": [
      {
        "rulePriority": 1,
        "description": "Keep last 30 release tagged images",
        "selection": {
          "tagStatus": "tagged",
          "tagPrefixList": ["release"],
          "countType": "imageCountMoreThan",
          "countNumber": 30
        },
        "action": {
          "type": "expire"
        }
      }
    ]
  }
  EOF
}
