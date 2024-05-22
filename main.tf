# --------------------------------------------------------------
# Creating S3 bucket for web hosting
# --------------------------------------------------------------

module "s3-web-hosting" {
  source = "./Modules/S3"

  bucket_name   = "web-hosting-terraform-conversion-project"
  force_destroy = true
  tags = {
    Deployment_method = "Terraform"
    Environment       = "Testing"
  }

  # Creating a bucket policy that enables public access to the bucket's objects.
  enable_bucket_policy = true
  policy_statements = [
    {
      effect                = "Allow"
      actions               = ["s3:GetObject"]
      principal_type        = "*"
      principal_identifiers = ["*"]
      resources             = ["${module.s3-web-hosting.bucket-arn}/*"]
    }
  ]

  # Creating public-read ACL for the bucket to be publicaly accessible.
  enable_ownership_controls = true
  object_ownership          = "BucketOwnerPreferred"

  enable_public_access_block = true
  block_public_acls          = false
  block_public_policy        = false
  ignore_public_acls         = false
  restrict_public_buckets    = false

  enable_acl = true
  acl        = "public-read"

  # Configuring a static website hosting.
  enable_website        = true
  index_document_suffix = "index.html"
}


# --------------------------------------------------------------
# Creating S3 bucket for input files
# --------------------------------------------------------------

module "s3-input-files" {
  source = "./Modules/S3"

  bucket_name   = "input-files-terraform-conversion-project"
  force_destroy = true
  tags = {
    Deployment_method = "Terraform"
    Environment       = "Testing"
  }

  # Setting the CORS configurations to enable only requests from webhosting bucket.
  enable_cors          = true
  cors_allowed_methods = ["PUT", "POST"]
  cors_allowed_origins = ["http://${module.s3-web-hosting.website-endpoint}"]
  cors_max_age_seconds = 3000
}


# --------------------------------------------------------------
# Creating S3 bucket for output files
# --------------------------------------------------------------

module "s3-output-files" {
  source = "./Modules/S3"

  bucket_name   = "output-files-terraform-conversion-project"
  force_destroy = true
  tags = {
    Deployment_method = "Terraform"
    Environment       = "Testing"
  }

  # Setting the CORS configurations to enable only requests from webhosting bucket
  enable_cors          = true
  cors_allowed_methods = ["GET"]
  cors_allowed_origins = ["http://${module.s3-web-hosting.website-endpoint}"]
  cors_max_age_seconds = 3000
}


# --------------------------------------------------------------
# Creating Amazon Cognito identity pool
# --------------------------------------------------------------

resource "aws_cognito_identity_pool" "users-pool" {
  identity_pool_name               = "TerraformProjectPool"
  allow_unauthenticated_identities = true
  allow_classic_flow               = true
  tags = {
    Deployment_method = "Terraform"
    Environment       = "Testing"
  }
}


# --------------------------------------------------------------------------
# Creating two IAM roles for both the identity pool and the lambda function.
# --------------------------------------------------------------------------

# Creating a cognito user role.
module "cognito-role" {
  source             = "./Modules/IAM Role"
  role_name          = "CognitoGuestRole"
  policy_name        = "CognitoGuestPolicy"
  policy_description = "A policy for Amazon Cognito identity pool to allow getting credentials, uploading and downloading images."
  actions            = ["sts:AssumeRoleWithWebIdentity"] 
  principals = [
    {
      type        = "Federated"
      identifiers = ["cognito-identity.amazonaws.com"]
    }
  ]
  conditions = [
    {
      test     = "StringEquals"
      variable = "cognito-identity.amazonaws.com:aud"
      values   = ["${aws_cognito_identity_pool.users-pool.id}"]
    },
    {
      test     = "ForAnyValue:StringLike"
      variable = "cognito-identity.amazonaws.com:amr"
      values   = ["unauthenticated"]
    }
  ]
  statements = [
    {
      effect    = "Allow"
      actions   = ["s3:PutObject"]
      resources = ["${module.s3-input-files.bucket-arn}/*"]
    },
    {
      effect    = "Allow"
      actions   = ["s3:GetObject"]
      resources = ["${module.s3-output-files.bucket-arn}/*"]
    },
    {
      effect    = "Allow"
      actions   = ["cognito-identity:GetCredentialsForIdentity"]
      resources = ["*"]
    }
  ]

  tags = {
    Deployment_method = "Terraform"
    Environment       = "Testing"
  }
}


# Associating the cognito role with cognito identity pool.
resource "aws_cognito_identity_pool_roles_attachment" "main" {
  identity_pool_id = aws_cognito_identity_pool.users-pool.id

  roles = {
    "unauthenticated" = module.cognito-role.role-arn
  }
}


# Creating a lambda-role.
module "lambda-role" {
  source             = "./Modules/IAM Role"
  role_name          = "ConvertionLambdaRole"
  policy_name        = "ConvertionLambdaPolicy"
  policy_description = "A policy for lambda function to get access to both input and output S3 buckets and CloudWatch logs."
  actions            = ["sts:AssumeRole"]
  principals = [
    {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  ]
  statements = [
    {
      effect    = "Allow"
      actions   = ["s3:PutObject"]
      resources = ["${module.s3-output-files.bucket-arn}/*"]
    },
    {
      effect    = "Allow"
      actions   = ["s3:GetObject"]
      resources = ["${module.s3-input-files.bucket-arn}/*"]
    },
    {
      effect    = "Allow"
      actions   = ["logs:*"]
      resources = ["arn:aws:logs:*:*:*"]
    }
  ]

  tags = {
    Deployment_method = "Terraform"
    Environment       = "Testing"
  }
}


# --------------------------------------------------------------
# Creating the lambda function for the conversion process
# --------------------------------------------------------------

# Archiving the python code for lambda.
data "archive_file" "lambda-code" {
  type        = "zip"
  source_file = "Lambda Files/lambda_function.py"
  output_path = "Lambda Files/lambda_function.zip"
}


# Creating the lambda function.
module "lamda-function" {
  source = "./Modules/Lambda"

  lambda_filename      = "Lambda Files/lambda_function.zip"
  lambda_function_name = "ConvertionLambdaFunction"
  lambda_role_arn      = module.lambda-role.role-arn
  lambda_handler       = "lambda_function.lambda_handler"
  lambda_runtime       = "python3.10"
  lambda_timeout       = 300
  source_code_hash     = data.archive_file.lambda-code.output_base64sha256
  environment_variables = {
    output_bucket_name = module.s3-output-files.bucket-name
  }

  tags = {
    Deployment_method = "Terraform"
    Environment       = "Testing"
  }

  # Creating pillow layer.
  layer_filename = "Lambda/Pillow-layer.zip"
  layer_name     = "PillowPackagePython310"
  layer_runtimes = ["python3.10"]

  # Giving permissions to get notified by S3 input files bucket. 
  source_arn = module.s3-input-files.bucket-arn

  # Triggering the lambda function when uploading a file to S3 input files bucket.
  bucket_id    = module.s3-input-files.bucket-id
  S3_events    = ["s3:ObjectCreated:*"]
  files_suffix = [".bmp", ".tiff", ".png", ".jpg", ".jpeg"]

}


# ------------------------------------------------------------------
# Creating the necessary configuration file for the javascript code.
# ------------------------------------------------------------------

resource "null_resource" "write_config" {
  provisioner "local-exec" {
    interpreter = local.is_windows ? ["PowerShell", "-Command"] : []
    command     = <<EOT
$jsonContent = '{ "id": "${aws_cognito_identity_pool.users-pool.id}", "region" : "${var.region}", "s3inputbucket" : "${module.s3-input-files.bucket-name}", "s3outputbucket" : "${module.s3-output-files.bucket-name}" }'
$jsonContent | Out-File -FilePath app/poolconfiguration.json -Encoding utf8
EOT
  }
}


# ------------------------------------------------------------------
# Uploading the static website files.
# ------------------------------------------------------------------

resource "aws_s3_object" "provision-web-files" {
  bucket = module.s3-web-hosting.bucket-id

  for_each     = fileset("app/", "**/*.*")
  depends_on   = [null_resource.write_config]
  key          = each.value
  source       = "app/${each.value}"
  content_type = lookup(local.mime_types, regex("\\.[^.]+$", each.value), null)
}