resource "aws_ecs_cluster" "aisk-prd" {
  name = "aisk-prd"
}

resource "aws_ecs_task_definition" "aisk-prd-app" {
  family                   = "aisk-prd-app"
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  container_definitions    = file("./task_definitions/prd_app_container_definitions.json")
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
