# -------------------------------------------------------------- #
# --------------------- S3 Module Variables -------------------- #
# -------------------------------------------------------------- #


# --------------------------------------------------------------
# Variables for the bucket
# --------------------------------------------------------------
variable "bucket_name" {
  description = "The name of the bucket"
  type        = string
}

variable "force_destroy" {
  description = "Whether to force destroy the bucket"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to assign to the bucket"
  type        = map(string)
  default     = {}
}


# --------------------------------------------------------------
# Variables for the bucket policy
# --------------------------------------------------------------

variable "enable_bucket_policy" {
  description = "Whether to create a bucket policy"
  type        = bool
  default     = false
}


variable "policy_statements" {
  description = "List of policy statements."
  type = list(object({
    effect                = string
    actions               = list(string)
    principal_type        = string
    principal_identifiers = list(string)
    resources             = list(string)
  }))
  default = []
}

# --------------------------------------------------------------
# Variables for ACL configurations
# --------------------------------------------------------------

variable "enable_ownership_controls" {
  description = "Whether to enable ownership controls"
  type        = bool
  default     = false
}

variable "object_ownership" {
  description = "Object ownership setting"
  type        = string
  default     = "BucketOwnerPreferred"
}

variable "enable_public_access_block" {
  description = "Whether to enable public access block or not."
  type        = bool
  default     = false
}

variable "block_public_acls" {
  description = "Block public ACLs."
  type        = bool
  default     = true
}

variable "block_public_policy" {
  description = "Block public policy."
  type        = bool
  default     = true
}

variable "ignore_public_acls" {
  description = "Ignore public ACLs."
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  description = "Restrict public buckets."
  type        = bool
  default     = true
}

variable "enable_acl" {
  description = "Whether to enable ACL or not."
  type        = bool
  default     = false
}

variable "acl" {
  description = "ACL type for the bucket."
  type        = string
  default     = "private"
}


# --------------------------------------------------------------
# Variables for website configurations
# --------------------------------------------------------------

variable "enable_website" {
  description = "Whether to enable website hosting"
  type        = bool
  default     = false
}

variable "index_document_suffix" {
  description = "Suffix for the index document"
  type        = string
  default     = "index.html"
}


# --------------------------------------------------------------
# Variables for CORS configurations
# --------------------------------------------------------------

variable "enable_cors" {
  description = "Whether to enable CORS or not."
  type        = bool
  default     = false
}

variable "cors_allowed_headers" {
  description = "Allowed headers for CORS configurations."
  type        = list(string)
  default     = ["*"]
}

variable "cors_allowed_methods" {
  description = "Allowed methods for CORS configurations."
  type        = list(string)
  default     = ["GET"]
}

variable "cors_allowed_origins" {
  description = "Allowed origins for CORS configurations."
  type        = list(string)
  default     = []
}

variable "cors_expose_headers" {
  description = "Expose headers for CORS configurations."
  type        = list(string)
  default     = []
}

variable "cors_max_age_seconds" {
  description = "Max age seconds for CORS configurations."
  type        = number
  default     = 0
}