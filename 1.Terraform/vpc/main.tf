terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

variable "test_vpc" {
  description = "VPC Name"
  default     = "default"
}

locals {
  common_tags = {
    Service = "network"
    Owner   = "netid"
  }
}

module "vpc" {
  source                   = "tedilabs/network/aws//modules/vpc"
  version                  = "0.24.0"
  name                     = var.test_vpc
  cidr_block               = "10.0.0.0/16"
  internet_gateway_enabled = true
  dns_hostnames_enabled    = true
  dns_support_enabled      = true
  tags                     = local.common_tags
}

module "test_pub_sn" {
  source  = "tedilabs/network/aws//modules/subnet-group"
  version = "0.24.0"
  name    = "${module.vpc.name}_pub_sn"
  subnets = {
    "${module.vpc.name}_pub_sn1" = {
      cidr_block           = "10.0.1.0/24"
      availability_zone_id = "apne2-az1"
    }
    "${module.vpc.name}_pub_sn2" = {
      cidr_block           = "10.0.2.0/24"
      availability_zone_id = "apne2-az3"
    }
  }
  tags   = local.common_tags
  vpc_id = module.vpc.id
}

module "test_pri_sn" {
  source  = "tedilabs/network/aws//modules/subnet-group"
  version = "0.24.0"
  name    = "${module.vpc.name}_pri_sn"
  subnets = {
    "${module.vpc.name}_pri_sn1" = {
      cidr_block           = "10.0.3.0/24"
      availability_zone_id = "apne2-az1"
    }
    "${module.vpc.name}_pri_sn2" = {
      cidr_block           = "10.0.4.0/24"
      availability_zone_id = "apne2-az3"
    }
  }
  tags   = local.common_tags
  vpc_id = module.vpc.id
}

module "test_pub_rt" {
  source  = "tedilabs/network/aws//modules/route-table"
  version = "0.24.0"
  name    = "${module.vpc.name}_pub_rt"
  vpc_id  = module.vpc.id
  subnets = module.test_pub_sn.ids
  ipv4_routes = [
    {
      cidr_block = "0.0.0.0/0"
      gateway_id = module.vpc.internet_gateway_id
    },
  ]
  tags = local.common_tags
}

module "test_pri_rt" {
  source      = "tedilabs/network/aws//modules/route-table"
  version     = "0.24.0"
  name        = "${module.vpc.name}_pri_rt"
  vpc_id      = module.vpc.id
  subnets     = module.test_pri_sn.ids
  ipv4_routes = []
  tags        = local.common_tags
}
