output "access_key" {
  value = aws_iam_access_key.user.id
}

output "secret_key" {
  value     = aws_iam_access_key.user.secret
  sensitive = true
}
