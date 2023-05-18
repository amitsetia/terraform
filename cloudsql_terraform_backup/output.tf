output "passwords" {
  description = "Passwords generated "
  value       = { for k, v in random_password.password : k => nonsensitive(v.result) if var.expose_password }
}

