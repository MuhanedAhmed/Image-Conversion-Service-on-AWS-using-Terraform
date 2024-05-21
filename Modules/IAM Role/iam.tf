# ----------------------------------------------------------------------------- #
# ---------------------------- IAM Role Module -------------------------------- #
# ----------------------------------------------------------------------------- #


# -----------------------------------------------------------------------------
# Creating policy document for the trust policy of iam-role.
# -----------------------------------------------------------------------------

data "aws_iam_policy_document" "trust-policy-document" {
  statement {
    effect  = "Allow"
    actions = var.actions

    dynamic "principals" {
      for_each = var.principals
      content {

        type        = principals.value["type"]
        identifiers = principals.value.identifiers
      }

    }

    dynamic "condition" {
      for_each = var.conditions
      content {
        test     = condition.value.test
        variable = condition.value.variable
        values   = condition.value.values
      }
    }
  }
}


# -----------------------------------------------------------------------------
# Creating a role for the Cognito user and attaching the trust policy with it.
# -----------------------------------------------------------------------------

resource "aws_iam_role" "iam-role" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.trust-policy-document.json
  tags = {
    Deployment_method = "Terraform"
    Environment       = "Testing"
  }
}


# -----------------------------------------------------------------------------
# Creating policy document for the cognito role's policy.
# -----------------------------------------------------------------------------

data "aws_iam_policy_document" "role-policy-document" {
  dynamic "statement" {
    for_each = var.statements
    content {
      effect    = statement.value.effect
      actions   = statement.value.actions
      resources = statement.value.resources
    }
  }
}


# -----------------------------------------------------------------------------
# Creating a policy for the iam role.
# -----------------------------------------------------------------------------

resource "aws_iam_policy" "role-policy" {
  name        = var.policy_name
  description = var.policy_description
  policy      = data.aws_iam_policy_document.role-policy-document.json
}


# -----------------------------------------------------------------------------
# Associating the iam role with its policy.
# -----------------------------------------------------------------------------

resource "aws_iam_role_policy_attachment" "role-policy-attach" {
  role       = aws_iam_role.iam-role.name
  policy_arn = aws_iam_policy.role-policy.arn
}