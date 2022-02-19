provider "random" {}

resource "random_string" "webhook_secret_key" {
  length = 32
  special = false
}
