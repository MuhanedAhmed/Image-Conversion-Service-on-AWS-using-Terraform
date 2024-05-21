# --------------------------------------------------------------
# Fetching the required provider version (AWS) 
# --------------------------------------------------------------

terraform {
  required_providers {
    aws = {

      source  = "hashicorp/aws"
      version = "5.40.0"
    }
  }
}


# --------------------------------------------------------------
# Setting the AWS provider's configurations and local values.
# --------------------------------------------------------------

provider "aws" {

  region  = var.region
  profile = "default"

}

locals {
  # Determining whether the OS is Windows or Linux.
  is_windows = substr(pathexpand("~"), 0, 1) == "/" ? false : true

  # Fetching the MIME types from mime.json file.
  mime_types = jsondecode(file("${path.module}/app/mime.json"))

}