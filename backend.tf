# --- root/backend.tf ---

terraform {
  backend "s3" {
    bucket = "demo-cpastone-project"
    key    = "project/remote.tfstate"
    region = "us-east-1"
  }
}
