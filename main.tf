terraform {
  required_providers {
      aws = {
          source = "hashicorp/aws"
          version = "~> 3.0"
      }
  }
}

terraform {
  backend "s3" {
    bucket = "devops-build-artifacts-eu-west-2"
    key    = "terraform_state"
    region = "eu-west-2"
  }
}

provider "aws" {
    region = "eu-west-2"
}

module "networks" {
    source = "./network"
    vpc_cidr = "10.0.0.0/16"
    vpc_name = "web-tier-vpc"
    subnet1_cidr = "10.0.1.0/24"
    subnet2_cidr = "10.0.2.0/24"
    subnet3_cidr = "10.0.3.0/24" # Public subnet used by NLB
}

module "compute" {
  source = "./compute"
  depends_on = [module.networks, module.dbtier] # Provision the underlying infra and database first
  size_of_ec2 = "t2.micro"
  instance_sg = module.networks.instance_sg
  private_subnet1 = module.networks.private-subnet1-id
  private_subnet2 = module.networks.private-subnet2-id
  public_subnet = module.networks.public-subnet3-id
  nlb_eip = module.networks.nlb-ip
  webapp_vpc = module.networks.webapp-vpc-id
  
}

module "dbtier" {
  source = "./datastore"
  depends_on = [module.networks]
  database_instance_size = "db.t3.micro"
  database_engine = "postgres"
  database_engine_version = 13
  private_subnet1 = module.networks.private-subnet1-id
  private_subnet2 = module.networks.private-subnet2-id
  db_security_groups = module.networks.dbtier-sg
}
