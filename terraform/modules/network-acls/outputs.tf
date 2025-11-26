#═══════════════════════════════════════════════════════════════
# NETWORK ACLs MODULE - OUTPUTS
#═══════════════════════════════════════════════════════════════

output "public_nacl_id" {
  description = "ID of the public subnet NACL"
  value       = aws_network_acl.public.id
}

output "private_nacl_id" {
  description = "ID of the private subnet NACL"
  value       = aws_network_acl.private.id
}

output "database_nacl_id" {
  description = "ID of the database subnet NACL"
  value       = aws_network_acl.database.id
}
