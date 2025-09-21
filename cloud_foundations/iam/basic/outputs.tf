output "service_accounts" {
  value = module.service_accounts
}

output "service_account_emails" {
  value = { for sa_key, sa_value in local.service_accounts : sa_key => sa_value.create ? module.service_accounts[sa_key].email : sa_value.email }
}
