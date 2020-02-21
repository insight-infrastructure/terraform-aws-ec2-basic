variable "public_key_path" {}

module "defaults" {
  source           = "../.."
  name             = ""
  local_public_key = var.public_key_path
}
