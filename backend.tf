terraform {
  backend "s3" {
    bucket         = "aunsh-terraform-state-bucket"
    key            = "dev/terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
