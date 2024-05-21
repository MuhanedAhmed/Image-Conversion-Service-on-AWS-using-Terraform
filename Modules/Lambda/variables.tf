# -------------------------------------------------------------- #
# --------------------- S3 Module Variables -------------------- #
# -------------------------------------------------------------- #


# --------------------------------------------------------------
# Variables for the python package layer (Pillow).
# --------------------------------------------------------------

variable "layer_filename" {
  description = "The filename for the Lambda layer."
  type        = string
}

variable "layer_name" {
  description = "The name of the Lambda layer."
  type        = string
}

variable "layer_runtimes" {
  description = "The compatible runtimes of the Lambda layer."
  type        = list(string)
}


# --------------------------------------------------------------
# Variables for the lambda function.
# --------------------------------------------------------------

variable "lambda_filename" {
  description = "The filename of the Lambda function code."
  type        = string
}

variable "lambda_function_name" {
  description = "The name of the Lambda function."
  type        = string
}

variable "lambda_role_arn" {
  description = "The ARN of lambda role."
  type        = string
}

variable "lambda_handler" {
  description = "The handler for the Lambda function."
  type        = string
}

variable "lambda_runtime" {
  description = "The runtime for the Lambda function."
  type        = string
}

variable "lambda_timeout" {
  description = "The timeout for the Lambda function."
  type        = number
}

variable "source_code_hash" {
  description = "The source code hash for the Lambda function."
  type        = string
}

variable "environment_variables" {
  description = "Environment variables for the Lambda function."
  type        = map(string)
}

variable "tags" {
  description = "Tags for the Lambda function."
  type        = map(string)
}


# --------------------------------------------------------------------
# Variables for giving the needed permissions for the lambda function.
# --------------------------------------------------------------------

variable "source_arn" {
  description = "The source ARN for Lambda permissions."
  type        = string
}


# --------------------------------------------------------------
# Variables for triggering the lambda function.
# --------------------------------------------------------------

variable "bucket_id" {
  description = "The ID of the S3 bucket that will trigger the lambda function."
  type        = string
}

variable "S3_events" {
  description = "The S3 events that will trigger the lambda function."
  type        = list(string)
}

variable "files_suffix" {
  description = "The suffix of targetted files to trigger the lambda function."
  type        = list(string)
}