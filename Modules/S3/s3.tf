# ----------------------------------------------------------------------------- #
# ------------------------------- S3 Module ----------------------------------- #
# ----------------------------------------------------------------------------- #


# -----------------------------------------------------------------------------
# Creating the bucket itself.
# -----------------------------------------------------------------------------

resource "aws_s3_bucket" "S3-bucket" {

  bucket        = var.bucket_name
  force_destroy = true

  tags = var.tags
}


# -----------------------------------------------------------------------------
# Creating policy document for the bucket policy.
# -----------------------------------------------------------------------------

data "aws_iam_policy_document" "policy-document" {
  count = var.enable_bucket_policy ? 1 : 0

  dynamic "statement" {
    for_each = var.policy_statements
    content {
      effect  = statement.value.effect
      actions = statement.value.actions
      principals {
        type        = statement.value.principal_type
        identifiers = statement.value.principal_identifiers
      }
      resources = statement.value.resources
    }
  }
}


# -----------------------------------------------------------------------------
# Creating a bucket policy.
# -----------------------------------------------------------------------------

resource "aws_s3_bucket_policy" "bucket-policy" {
  count = var.enable_bucket_policy ? 1 : 0

  bucket = aws_s3_bucket.S3-bucket.id
  policy = data.aws_iam_policy_document.policy-document[0].json
}



# -----------------------------------------------------------------------------
# Configuring ACL for the bucket.
# -----------------------------------------------------------------------------

resource "aws_s3_bucket_ownership_controls" "ownership" {
  count = var.enable_ownership_controls ? 1 : 0

  bucket = aws_s3_bucket.S3-bucket.id
  rule {
    object_ownership = var.object_ownership
  }
}


resource "aws_s3_bucket_public_access_block" "public-acces" {
  count = var.enable_public_access_block ? 1 : 0

  bucket                  = aws_s3_bucket.S3-bucket.id
  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

resource "aws_s3_bucket_acl" "bucket-acl" {
  count = var.enable_acl ? 1 : 0

  depends_on = [
    aws_s3_bucket_ownership_controls.ownership,
    aws_s3_bucket_public_access_block.public-acces,
  ]

  bucket = aws_s3_bucket.S3-bucket.id
  acl    = var.acl
}


# -----------------------------------------------------------------------------
# Configuring a static website hosting..
# -----------------------------------------------------------------------------

resource "aws_s3_bucket_website_configuration" "website-configurations" {
  count = var.enable_website ? 1 : 0

  bucket = aws_s3_bucket.S3-bucket.id

  index_document {
    suffix = var.index_document_suffix
  }
}


# -----------------------------------------------------------------------------
# Setting the CORS configurations.
# -----------------------------------------------------------------------------

resource "aws_s3_bucket_cors_configuration" "cors-configurations" {
  count = var.enable_cors ? 1 : 0

  bucket = aws_s3_bucket.S3-bucket.id

  cors_rule {
    allowed_headers = var.cors_allowed_headers
    allowed_methods = var.cors_allowed_methods
    allowed_origins = var.cors_allowed_origins
    expose_headers  = var.cors_expose_headers
    max_age_seconds = var.cors_max_age_seconds
  }
}