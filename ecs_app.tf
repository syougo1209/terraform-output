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
