module "network" {
  count  = var.create_vpc ? 1 : 0
  source = "./modules/network"

  env  = var.env
  tags = var.tags
}

module "compute" {
  source = "./modules/compute"

  env  = var.env
  tags = var.tags

  vpc_id = var.create_vpc ? module.network[0].vpc_id : var.vpc_id
  private_subnets = var.create_vpc ? module.network[0].private_subnets : var.private_subnets
  public_subnets = var.create_vpc ? module.network[0].public_subnets : var.public_subnets

  aurora_sg = module.aurora.aurora_sg
  efs_sg = module.efs.efs_sg

  wp_name = var.project
  wp_init = var.wp_init
  wp_region = var.region
  wp_efs_id = module.efs.efs_id
  wp_db_host = module.aurora.endpoint
  wp_db_name = var.database_name
  wp_db_user = var.master_username
  wp_db_password = var.master_password

  asg_desired_capacity = var.desired_capacity
  access_cidrs = concat([var.my_ip], var.custom_ips)
  ssh_pub_key = var.ssh_pub_key
  create_bastion = var.create_bastion
  enable_alb_https = var.enable_alb_https
  certificate_arn = var.certificate_arn
}

module "aurora" {
  source = "./modules/data/rds"

  env  = var.env
  tags = var.tags

  vpc_id = var.create_vpc ? module.network[0].vpc_id : var.vpc_id
  private_subnets = var.create_vpc ? module.network[0].private_subnets : var.private_subnets

  master_username = var.master_username
  master_password = var.master_password
  database_name = var.database_name
}

module "efs" {
  source = "./modules/data/efs"

  env  = var.env
  tags = var.tags

  vpc_id = var.create_vpc ? module.network[0].vpc_id : var.vpc_id
  private_subnets = var.create_vpc ? module.network[0].private_subnets : var.private_subnets
}

output "alb_address" {
  value = module.compute.alb_domain
}
