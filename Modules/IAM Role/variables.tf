# -------------------------------------------------------------- #
# ----------------- IAM Role Module Variables ------------------ #
# -------------------------------------------------------------- #



# --------------------------------------------------------------
# Variables for iam role
# --------------------------------------------------------------

variable "role_name" {
  description = "The name of the IAM role."
  type        = string
}


# --------------------------------------------------------------
# Variables for iam policy 
# --------------------------------------------------------------

variable "policy_name" {
  description = "The name of IAM policy."
  type        = string
}

variable "policy_description" {
  description = "The description of IAM policy."
  type        = string
}


# --------------------------------------------------------------
# Variables for trust policy document
# --------------------------------------------------------------

variable "actions" {
  description = "The allowed actions for the trust policy."
  type        = list(string)
}

variable "principals" {
  description = "The allowed principals for the rust policy."
  type = list(object({
    type        = string
    identifiers = list(string)
  }))
}

variable "conditions" {
  description = "A list of condition blocks for the trust policy document."
  type = list(object({
    test     = string
    variable = string
    values   = list(string)
  }))
  default = []

}


# --------------------------------------------------------------
# Variables for policy document
# --------------------------------------------------------------

variable "statements" {
  description = "A list of statements for the policy document."
  type = list(object({
    effect    = string
    actions   = list(string)
    resources = list(string)
  }))
}




