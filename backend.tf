terraform {
    backend "s3" {
        bucket = "my-terraform-state-bucket"
        key = "dev/terraform.tfstate"
        region = "eu-north-1"
        dynamondb_table = "terraform-locks"
        encrypt = true

    }
}