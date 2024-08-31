output "user_access_key" {
  value = local.create_user ? module.user[0].access_key : null
}

output "user_secret_key" {
  value     = local.create_user ? module.user[0].secret_key : null
  sensitive = true
}
