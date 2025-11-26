
# NETWORK ACLs MODULE - Subnet-Level Firewall



# PUBLIC SUBNET NETWORK ACL


resource "aws_network_acl" "public" {
  vpc_id     = var.vpc_id
  subnet_ids = var.public_subnet_ids

  tags = {
    Name = "${var.project_name}-public-nacl"
    Tier = "Public"
    Note = "Protects public subnets (web tier)"
  }
}

#───────────────────────────────────────────────────────────────
# PUBLIC SUBNET - INBOUND RULES
#───────────────────────────────────────────────────────────────

# DENY RULES (100-199) - Block known threats

resource "aws_network_acl_rule" "public_inbound_deny_known_attacker_1" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 100
  egress         = false # Inbound rule
  protocol       = -1    # All protocols
  rule_action    = "deny"
  cidr_block     = "203.0.113.0/24" # Example: known malicious subnet
  from_port      = 0
  to_port        = 0
}

resource "aws_network_acl_rule" "public_inbound_deny_rdp" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 110
  egress         = false
  protocol       = "tcp"
  rule_action    = "deny"
  cidr_block     = "0.0.0.0/0"
  from_port      = 3389 # RDP port
  to_port        = 3389
}

# ALLOW RULES (200-299) - Allow legitimate traffic

resource "aws_network_acl_rule" "public_inbound_allow_http" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 200
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "public_inbound_allow_https" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 210
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "public_inbound_allow_ssh_from_home" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 220
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.admin_ip_cidr # Your home/office IP only
  from_port      = 22
  to_port        = 22
}

resource "aws_network_acl_rule" "public_inbound_allow_ephemeral" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 230
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024  # Ephemeral port range start
  to_port        = 65535 # Ephemeral port range end
}

#───────────────────────────────────────────────────────────────
# PUBLIC SUBNET - OUTBOUND RULES
#───────────────────────────────────────────────────────────────

# ALLOW RULES (200-299) - Allow responses

resource "aws_network_acl_rule" "public_outbound_allow_http" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 200
  egress         = true # Outbound rule
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "public_outbound_allow_https" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 210
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "public_outbound_allow_ephemeral" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 220
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "public_outbound_allow_to_private" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 230
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr # To private subnets
  from_port      = 0
  to_port        = 65535
}

#───────────────────────────────────────────────────────────────
# PRIVATE SUBNET NETWORK ACL
#───────────────────────────────────────────────────────────────

resource "aws_network_acl" "private" {
  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.project_name}-private-nacl"
    Tier = "Private"
    Note = "Protects private subnets (app tier)"
  }
}

#───────────────────────────────────────────────────────────────
# PRIVATE SUBNET - INBOUND RULES
#───────────────────────────────────────────────────────────────

# DENY RULES (100-199)

resource "aws_network_acl_rule" "private_inbound_deny_internet" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 100
  egress         = false
  protocol       = -1
  rule_action    = "deny"
  cidr_block     = "0.0.0.0/0" # No direct internet access
  from_port      = 0
  to_port        = 0
}

# ALLOW RULES (200-299) - Only from VPC

resource "aws_network_acl_rule" "private_inbound_allow_from_vpc" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 200
  egress         = false
  protocol       = -1
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr # Only from within VPC
  from_port      = 0
  to_port        = 0
}

#───────────────────────────────────────────────────────────────
# PRIVATE SUBNET - OUTBOUND RULES
#───────────────────────────────────────────────────────────────

resource "aws_network_acl_rule" "private_outbound_allow_to_vpc" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 200
  egress         = true
  protocol       = -1
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr # Only to VPC (includes VPC endpoints)
  from_port      = 0
  to_port        = 0
}

resource "aws_network_acl_rule" "private_outbound_allow_https_to_internet" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 210
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

#───────────────────────────────────────────────────────────────
# DATABASE SUBNET NETWORK ACL
#───────────────────────────────────────────────────────────────

resource "aws_network_acl" "database" {
  vpc_id     = var.vpc_id
  subnet_ids = var.database_subnet_ids

  tags = {
    Name = "${var.project_name}-database-nacl"
    Tier = "Database"
    Note = "Protects database subnets (most restrictive)"
  }
}

#───────────────────────────────────────────────────────────────
# DATABASE SUBNET - INBOUND RULES
#───────────────────────────────────────────────────────────────

# DENY ALL except from private subnets

resource "aws_network_acl_rule" "database_inbound_deny_internet" {
  network_acl_id = aws_network_acl.database.id
  rule_number    = 100
  egress         = false
  protocol       = -1
  rule_action    = "deny"
  cidr_block     = "0.0.0.0/0" # Block all internet
  from_port      = 0
  to_port        = 0
}

resource "aws_network_acl_rule" "database_inbound_allow_from_private" {
  network_acl_id = aws_network_acl.database.id
  rule_number    = 200
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "10.0.11.0/24" # Private subnet 1
  from_port      = 0
  to_port        = 65535
}

resource "aws_network_acl_rule" "database_inbound_allow_from_private_2" {
  network_acl_id = aws_network_acl.database.id
  rule_number    = 210
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "10.0.12.0/24" # Private subnet 2
  from_port      = 0
  to_port        = 65535
}

#───────────────────────────────────────────────────────────────
# DATABASE SUBNET - OUTBOUND RULES
#───────────────────────────────────────────────────────────────

resource "aws_network_acl_rule" "database_outbound_deny_internet" {
  network_acl_id = aws_network_acl.database.id
  rule_number    = 100
  egress         = true
  protocol       = -1
  rule_action    = "deny"
  cidr_block     = "0.0.0.0/0" # No outbound internet
  from_port      = 0
  to_port        = 0
}

resource "aws_network_acl_rule" "database_outbound_allow_to_private" {
  network_acl_id = aws_network_acl.database.id
  rule_number    = 200
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr # Only to VPC
  from_port      = 0
  to_port        = 65535
}
