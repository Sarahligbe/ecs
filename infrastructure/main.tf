module "networking" {
  source              = "./modules/networking"
  ecs_cluster_name       = var.ecs_cluster_name
  vpc_cidr_block         = var.vpc_cidr_block
  private_subnet_count   = var.private_subnet_count
  public_subnet_count    = var.public_subnet_count
  enable_private_networking = true
}

module "alb" {
  source      = "./modules/alb"
  ecs_cluster_name = var.ecs_cluster_name
  vpc_id = module.networking.vpc_id
  public_subnet_ids = module.networking.public_subnet_ids
}

module "ecs" {
  source                = "./modules/ecs"
  ecs_cluster_name = var.ecs_cluster_name
  vpc_id = module.networking.vpc_id
  use_public_ip = module.networking.use_public_ip
  subnet_ids = module.networking.subnet_ids
  alb_sg_id = module.alb.alb_sg_id
  target_group_arn     = module.alb.target_group_arn
}

module "autoscaling" {
  source           = "./modules/autoscaling"
  ecs_cluster_name = var.ecs_cluster_name
  ecs_service_name = module.ecs.service_name
  alb_arn_suffix   = module.alb.alb_arn_suffix
  alb_tg_arn_suffix   = module.alb.alb_tg_arn_suffix
  min_capacity = var.min_capacity
  max_capacity = var.max_capacity
}

module "waf" {
  source      = "./modules/waf"
  ecs_cluster_name = var.ecs_cluster_name
  alb_arn     = module.alb.alb_arn
}