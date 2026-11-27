# Holds the Terraform state for infra/. Created here because something has
# to make the bucket before anything can store state in it.
module "s3" {
  source = "./modules/s3"

  bucket_name = var.state_bucket_name
}

# Lives in bootstrap so that destroying infra/ does not delete the images.
module "ecr" {
  source = "./modules/ecr"

  repository_name       = var.ecr_repository_name
  image_tag_mutability  = var.image_tag_mutability
  scan_on_push          = var.scan_on_push
  image_retention_count = var.image_retention_count
}

resource "aws_ssm_parameter" "image_tag" {
  name  = "/${var.project_name}/image_tag"
  type  = "String"
  value = "e499857"

  lifecycle {
    ignore_changes = [value]
  }
}

module "github_oidc" {
  source = "./modules/github-oidc"

  project_name            = var.project_name
  github_owner            = "smohamed99"
  github_repo             = "PostPrep-ECS-Terraform."
  ecr_repository_arn      = module.ecr.repository_arn
  state_bucket_arn        = module.s3.bucket_arn
  image_tag_parameter_arn = aws_ssm_parameter.image_tag.arn
}