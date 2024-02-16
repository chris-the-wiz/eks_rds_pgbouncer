variable "region" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "public_subnets_ids"{
  type = list(string)
}

variable "vpcid" {
    type = string
}

#variable "db_subnet_group_name"{
#  type = string
#}


//Create rds instance using the variables
data "aws_subnets" "public_subnets" {
  filter {
    name = "tag:kubernetes.io/cluster/${var.cluster_name}"
    values = ["shared"]
  }
  filter {
    name = "tag:kubernetes.io/role/elb"
    values = ["1"]
  }
}

resource "aws_db_subnet_group" "my_db_subnet_group" {
  name       = "my-db-subnet-group"
  subnet_ids = data.aws_subnets.public_subnets.ids
  description = "Subnet group for RDS in my VPC"
}


resource "aws_security_group" "my_db_security_group" {
  vpc_id = var.vpcid

  // Define ingress rules as per your requirements
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  // Allow outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "my_db_instance" {
  identifier            = "assdb"
  allocated_storage     = 20
  engine                = "postgres" # Update to postgres
  engine_version        = "15.5"  # Update to PostgreSQL 15.2-R2
  instance_class        = "db.t3.micro"
  //name                  = "postgres"
  username              = "postgres"
  password              = "postgres"
  publicly_accessible  = true  # Set to true for public access
  skip_final_snapshot   = true

  vpc_security_group_ids = [aws_security_group.my_db_security_group.id]

#  db_subnet_group_name = var.db_subnet_group_name
   db_subnet_group_name = "my-db-subnet-group"


  tags = {
    Name = "MyAssInstance"
  }


}



resource "local_file" "configmap" {
  filename = "${path.module}/../../statefulset_generated.yaml"
  content  = templatefile("${path.module}/statefulset.yaml", {
    rdsdns = local.db_dns_name, 
  })
}

locals {
  //output the db endpoint

   db_endpoint = aws_db_instance.my_db_instance.endpoint
   db_parts = split(":", local.db_endpoint)
   db_dns_name = local.db_parts[0]
   
}




