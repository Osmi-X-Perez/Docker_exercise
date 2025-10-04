terraform {
    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "~> 6.0"
      }
    }
}

provider "aws" {
    region = "us-east-1"
}


resource "aws_s3_bucket" "dockerBucket" {
  bucket = "smar-docker-hands-on-364474747474474"

  tags = {
    Name        = "my_Docker_hands_on_bucket-364474747474474"
  }
}

resource "aws_s3_bucket_versioning" "versioning_Set" {
  bucket = aws_s3_bucket.dockerBucket.id
  versioning_configuration {
    status = "Disabled"
  }
}