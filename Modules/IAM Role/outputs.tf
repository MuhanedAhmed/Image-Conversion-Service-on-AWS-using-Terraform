# -------------------------------------------------------------- #
# ------------------ IAM Role Module Outputs ------------------- #
# -------------------------------------------------------------- #

output "role-arn" {
  description = "The ARN of created iam role."
  value       = aws_iam_role.iam-role.arn
}