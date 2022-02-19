module "iam_policies" {
  source = "./modules/iam/policies"
}

module "codebuild_role" {
  source = "./modules/iam"
  name = "codebuild"
  identifier = "codebuild.amazonaws.com"
  policy = module.iam_policies.aws_iam_policy_document.codebuild
}

resource "aws_codebuild_project" "aisk-app-build" {
  name         = "aisk-app-build"
  service_role = module.codebuild_role.iam_role_arn

  source {
    type = "CODEPIPELINE"
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    type            = "LINUX_CONTAINER"
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:2.0"
    privileged_mode = true
  }
}
