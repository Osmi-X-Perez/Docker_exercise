variable "ami_for_ec2" {
  description = "AMI for EC2 launch"
  type = string
  default = "ami-052064a798f08f0d3"
}

variable "instance_type" {
  description = "Instance type for my test EC2"
  type = string
  default = "t3.small"
}

variable "AZ" {
  description = "AZ where I want to place my resources"
  type = string
  default = "us-east-1a"
}

variable "subnet" {
    description = "Subnet for the instance"
    type = string
  
}

variable "SG" {
  description = "Security Groups"
  type = list(string)
}

variable "user_data" {
  description = "scripts for the machine"
  type = string
  default = ""
}

variable "Tags" {
    description = "Tags for my instances"
    type = map(string)
    default = {}
}

variable "Role" {
  description = "Role for the instance"
  type = string
  default = ""
}