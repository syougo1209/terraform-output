output "codebuild_policy" {
  value= data.aws_iam_policy_document.codebuild.json
  description = "codebuildの他リソース操作権限"
}

output "codepipeline_policy" {
  value= data.aws_iam_policy_document.codepipeline.json
  description = "codepipelineの他リソース操作権限"
}

output "ecs_task_execution_policy" {
  value= data.aws_iam_policy_document.ecs_task_execution.json
  description = "ECS Fargateの他リソース操作権限"
}
