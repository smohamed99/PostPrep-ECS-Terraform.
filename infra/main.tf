# Referenced, never created. If Terraform owned the zone, a destroy would
# delete it, produce new nameservers, and break the Cloudflare delegation.
data "aws_route53_zone" "labs" {
  name         = var.hosted_zone_name
  private_zone = false
}

data "aws_ssm_parameter" "image_tag" {
  name = "/${var.project_name}/image_tag"
}

module "vpc" {
  source = "./modules/vpc"

  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
  az_count     = var.az_count
}

module "security" {
  source = "./modules/security"

  project_name   = var.project_name
  vpc_id         = module.vpc.vpc_id
  container_port = var.container_port
}

module "acm" {
  source = "./modules/acm"

  project_name   = var.project_name
  domain_name    = var.domain_name
  hosted_zone_id = data.aws_route53_zone.labs.zone_id
}

module "alb" {
  source = "./modules/alb"

  project_name      = var.project_name
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  security_group_id = module.security.alb_security_group_id
  certificate_arn   = module.acm.certificate_arn
  container_port    = var.container_port
}

module "ecs" {
  source = "./modules/ecs"

  project_name        = var.project_name
  aws_region          = var.aws_region
  private_subnet_ids  = module.vpc.private_subnet_ids
  security_group_id   = module.security.ecs_security_group_id
  target_group_arn    = module.alb.target_group_arn
  ecr_repository_name = var.ecr_repository_name
  image_tag           = nonsensitive(data.aws_ssm_parameter.image_tag.value)
  container_port      = var.container_port
  task_cpu            = var.task_cpu
  task_memory         = var.task_memory
  desired_count       = var.desired_count

  # The service cannot register targets until the listener exists.
  depends_on = [module.alb]
}

# An alias, not a CNAME: resolves to the load balancer's current addresses
# automatically and costs nothing to query.
resource "aws_route53_record" "app" {
  zone_id = data.aws_route53_zone.labs.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = module.alb.alb_dns_name
    zone_id                = module.alb.alb_zone_id
    evaluate_target_health = true
  }
}