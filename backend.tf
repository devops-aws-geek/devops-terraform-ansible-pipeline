# --- root/backend.tf ---

terraform {
  backend "s3" {
    bucket = "tf-bucket-batch906"
    key    = "project/remote.tfstate"
    region = "us-east-1"
  }
}
