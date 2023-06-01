output "vpc_name" {
  value = module.vpc.name
}

output "vpc_id" {
  value = module.vpc.id
}

output "vpc_cidr" {
  value = module.vpc.cidr_block
}

output "subnet_groups" {
  value = {
    public  = module.test_pub_sn
    private = module.test_pub_sn
  }
}
