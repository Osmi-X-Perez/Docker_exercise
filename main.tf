#---------------NETWORK RESOURCES-------------------------------
#VPC
resource "aws_vpc" "dockerVPC" {
    cidr_block = "192.168.0.0/16"
    enable_dns_support = true
    enable_dns_hostnames = true
    tags = {
        Name = "${var.prefix}_vpc"
    }
  }
#Internet Gateway
resource "aws_internet_gateway" "myIGW" {
  vpc_id = aws_vpc.dockerVPC.id
  tags = {
        Name = "${var.prefix}_IGW"
    }
}
#Public subnet
resource "aws_subnet" "mySubnet" {
  vpc_id = aws_vpc.dockerVPC.id
  cidr_block = "192.168.0.0/17"
  availability_zone = var.AZ
  map_public_ip_on_launch = true
  tags = {
        Name = "${var.prefix}_subnet"
    }
}
#Route table
resource "aws_route_table" "myRouteTable" {
  vpc_id = aws_vpc.dockerVPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myIGW.id
  }
  tags = {
    Name = "${var.prefix}-RouteTable"
  }
}
#Route association
resource "aws_route_table_association" "myRTAssociation" {
  subnet_id = aws_subnet.mySubnet.id
  route_table_id = aws_route_table.myRouteTable.id
}
#Security group
resource "aws_security_group" "mySG" {
  name = "mySG"
  vpc_id = aws_vpc.dockerVPC.id
  tags = {
    Name = "${var.prefix}-SG"
  }
}
#Ingress rule
resource "aws_vpc_security_group_ingress_rule" "myIngressRule" {
  security_group_id = aws_security_group.mySG.id
  cidr_ipv4 = "187.200.117.93/32"
  from_port = 80
  ip_protocol = "tcp"
  to_port = 80
}
#Egress rule
resource "aws_vpc_security_group_egress_rule" "myEgressRule" {
  security_group_id = aws_security_group.mySG.id
  cidr_ipv4 = "0.0.0.0/0"
  #from_port = 0
  ip_protocol = "-1"
  #to_port = 0
}

#---------------IAM ROLES-------------------------------------


resource "aws_iam_role" "server_role" {
  name = "ec2-ssm-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.server_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_instance_profile" "ec2_ssm_profile" {
  name = "ec2-ssm-instance-profile"
  role = aws_iam_role.server_role.name
}



#---------------EC2 RESOURCES------------------------------------
#Key Pair


# EC2 instance
module "server_1" {

  providers = {
    aws = aws
  }
  source = "./modules/ec2_instance"
  SG = [aws_security_group.mySG.id]
  subnet = aws_subnet.mySubnet.id
  user_data = "${file("push_img.sh")}"
  
  Tags = {
    Name = "${var.prefix}-instance_1"
  }
}

# Ec2 instance 2

module "server_2" {
  
  providers = {
    aws = aws
  }
  source = "./modules/ec2_instance"
  SG = [aws_security_group.mySG.id] 
  subnet = aws_subnet.mySubnet.id
  Role = aws_iam_instance_profile.ec2_ssm_profile.name
  depends_on = [
    module.s3_bucket  ,  module.server_1
  ]

  user_data = <<-EOF
    #!/bin/bash
    sleep 3m
    sudo yum -y update
    sudo yum -y install docker
    sudo systemctl start docker
    sudo systemctl enable docker
    cd /home/ec2-user
    USERNAME=$(echo operezx)
    PASS=$(echo Y0g_Sothoth@)
    sudo docker login -u $USERNAME -p $PASS
    sudo docker pull operezx/devops_excercises_osmar:latest
    sudo docker save -o mi_imagen.tar operezx/devops_excercises_osmar:latest
    sudo aws s3 cp /home/ec2-user/mi_imagen.tar  s3://${module.s3_bucket.bucket_name} 
  EOF

  Tags = {
  Name = "${var.prefix}-instance_2"
  }
}
#------------------S3-----------------------------------------------------
# S3 bucket

module "s3_bucket" {
  source = "./modules/s3_bucket"
}


