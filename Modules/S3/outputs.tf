# -------------------------------------------------------------- #
# --------------------- S3 Module Outputs ---------------------- #
# -------------------------------------------------------------- #


output "bucket-id" {
  description = "The ID of the created bucket."
  value       = aws_s3_bucket.S3-bucket.id
}

output "bucket-arn" {
  description = "The ARN of the created bucket."
  value       = aws_s3_bucket.S3-bucket.arn
}

output "bucket-name" {
  description = "The name of the created bucket."
  value       = aws_s3_bucket.S3-bucket.bucket
}

output "website-endpoint" {
  description = "The endpoint of the static hosted website."
  value       = var.enable_website ? aws_s3_bucket_website_configuration.website-configurations[0].website_endpoint : ""
}