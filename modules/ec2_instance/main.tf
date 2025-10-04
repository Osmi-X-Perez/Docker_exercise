terraform {
    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "~> 6.0"
      }
    }
}

/*provider "aws" {
    region = "us-east-1"
}
*/
resource "aws_instance" "DockerInstance" {
    ami = var.ami_for_ec2
    instance_type = var.instance_type
    availability_zone = var.AZ
    subnet_id = var.subnet
    vpc_security_group_ids = var.SG
    user_data = var.user_data
    tags = var.Tags
    iam_instance_profile = var.Role
  
}