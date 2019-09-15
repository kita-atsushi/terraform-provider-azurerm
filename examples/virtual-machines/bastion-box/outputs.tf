output "vm_fqdn" {
  value = "${azurerm_public_ip.jumpserver.fqdn}"
}

output "ssh_command" {
  value = "ssh ${local.admin_username}@${azurerm_public_ip.jumpserver.fqdn}"
}
