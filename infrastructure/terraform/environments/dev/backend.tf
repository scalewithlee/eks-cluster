terraform {
  backend "s3" {
    bucket       = "tf-state-bucket-1746822481"
    key          = "dev/terraform.tfstate"
    region       = "us-west-2"
    encrypt      = true
    use_lockfile = true # Use S3 native state locking
  }
}
