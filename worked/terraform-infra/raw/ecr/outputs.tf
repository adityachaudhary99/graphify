output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.api.repository_url
}

output "ecr_repository_arn" {
  description = "ECR repository ARN"
  value       = aws_ecr_repository.api.arn
}

output "github_actions_access_key_id" {
  description = "Access Key ID for GitHub Actions (add to GitHub Secrets as AWS_ACCESS_KEY_ID)"
  value       = aws_iam_access_key.github_actions.id
  sensitive   = true
}

output "github_actions_secret_access_key" {
  description = "Secret Access Key for GitHub Actions (add to GitHub Secrets as AWS_SECRET_ACCESS_KEY)"
  value       = aws_iam_access_key.github_actions.secret
  sensitive   = true
}
