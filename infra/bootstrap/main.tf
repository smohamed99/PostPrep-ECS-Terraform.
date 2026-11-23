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

# Tell Terraform these resources moved into modules rather than being
# destroyed and recreated. Delete these blocks once the move has applied.
moved {
  from = aws_s3_bucket.tfstate
  to   = module.s3.aws_s3_bucket.this
}

moved {
  from = aws_s3_bucket_versioning.tfstate
  to   = module.s3.aws_s3_bucket_versioning.this
}

moved {
  from = aws_s3_bucket_server_side_encryption_configuration.tfstate
  to   = module.s3.aws_s3_bucket_server_side_encryption_configuration.this
}

moved {
  from = aws_s3_bucket_public_access_block.tfstate
  to   = module.s3.aws_s3_bucket_public_access_block.this
}

moved {
  from = aws_ecr_repository.app
  to   = module.ecr.aws_ecr_repository.this
}

moved {
  from = aws_ecr_lifecycle_policy.app
  to   = module.ecr.aws_ecr_lifecycle_policy.this
}