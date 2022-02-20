output "codebuild_policy" {
  value= data.aws_iam_policy_document.codebuild.json
  description = "codebuildの他リソース操作権限"
}

output "codepipeline_policy" {
  value= data.aws_iam_policy_document.codepipeline.json
  description = "codepipelineの他リソース操作権限"
}
