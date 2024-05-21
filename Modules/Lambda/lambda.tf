# ----------------------------------------------------------------------------- #
# ----------------------------- Lambda Module --------------------------------- #
# ----------------------------------------------------------------------------- #


# -----------------------------------------------------------------------------
# Creating a layer for the python package.
# -----------------------------------------------------------------------------

resource "aws_lambda_layer_version" "my-layer" {
  filename            = var.layer_filename
  layer_name          = var.layer_name
  compatible_runtimes = var.layer_runtimes
}


# -----------------------------------------------------------------------------
# Creating the function itself.
# -----------------------------------------------------------------------------

resource "aws_lambda_function" "convertion-lambda-function" {
  filename         = var.lambda_filename
  function_name    = var.lambda_function_name
  role             = var.lambda_role_arn
  handler          = var.lambda_handler
  layers           = [aws_lambda_layer_version.my-layer.arn]
  runtime          = var.lambda_runtime
  timeout          = var.lambda_timeout
  source_code_hash = var.source_code_hash

  environment {
    variables = var.environment_variables
  }

  tags = var.tags
}


# -----------------------------------------------------------------------------
# Giving the S3 input files bucket permission to access the lambda function.
# -----------------------------------------------------------------------------

resource "aws_lambda_permission" "allow-input-bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.convertion-lambda-function.arn
  principal     = "s3.amazonaws.com"
  source_arn    = var.source_arn
}


# -----------------------------------------------------------------------------
# Triggering the lambda function when uploading a file to S3 input files bucket.
# -----------------------------------------------------------------------------

resource "aws_s3_bucket_notification" "bucket-notification" {
  bucket = var.bucket_id

  dynamic "lambda_function" {
    for_each = var.files_suffix
    content {
      lambda_function_arn = aws_lambda_function.convertion-lambda-function.arn
      events              = var.S3_events
      filter_suffix       = lambda_function.value
    }
  }

  depends_on = [aws_lambda_permission.allow-input-bucket]
}