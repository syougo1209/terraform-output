//iampolicy作成用のdata only moduleを呼び出す
module "iam_policies" {
  source = "./modules/iam/policies"
}
