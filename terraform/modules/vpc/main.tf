# VPC Module - Main Configuration
# This creates a three-tier VPC (public, private, database)

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Public Subnets
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet-${count.index + 1}"
    Tier = "Public"
  }
}

# Private Subnets
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.project_name}-private-subnet-${count.index + 1}"
    Tier = "Private"
  }
}

# Database Subnets
resource "aws_subnet" "database" {
  count = length(var.database_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.database_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.project_name}-database-subnet-${count.index + 1}"
    Tier = "Database"
  }
}

# Elastic IP for NAT Gateway - COMMENTED OUT (using VPC Endpoints instead)
#resource "aws_eip" "nat" {
# domain = "vpc"
#
# tags = {
#  Name = "${var.project_name}-nat-eip"
#}
#
#depends_on = [aws_internet_gateway.main]
#}

# NAT Gateway (for private subnets to reach internet)
#resource "aws_nat_gateway" "main" {
# allocation_id = aws_eip.nat.id
#  subnet_id     = aws_subnet.public[0].id
#
# tags = {
#   Name = "${var.project_name}-nat-gateway"
# }
#
# depends_on = [aws_internet_gateway.main]
#}

# Route Table for Public Subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# Route Table for Private Subnets
# Route Table for Private Subnets
# MODIFIED: Removed NAT Gateway route (using VPC Endpoints instead)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  # NO ROUTES - Private subnet uses VPC Endpoints for AWS services
  # route {
  #   cidr_block     = "0.0.0.0/0"
  #   nat_gateway_id = aws_nat_gateway.main.id
  # }

  tags = {
    Name = "${var.project_name}-private-rt"
    Note = "No internet route - VPC Endpoints only"
  }
}

# Route Table for Database Subnets (no internet access)
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-database-rt"
  }
}

# Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Associate Private Subnets with Private Route Table
resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# Associate Database Subnets with Database Route Table
resource "aws_route_table_association" "database" {
  count = length(aws_subnet.database)

  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}



#═══════════════════════════════════════════════════════════════
# VPC ENDPOINTS (Cost-Effective Alternative to NAT Gateway)
#═══════════════════════════════════════════════════════════════

# VPC Endpoint for S3 (Gateway Endpoint - FREE!)
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"

  # Gateway endpoint type (FREE - no hourly charges)
  vpc_endpoint_type = "Gateway"

  # Associate with private and database route tables
  route_table_ids = [
    aws_route_table.private.id,
    aws_route_table.database.id
  ]

  tags = {
    Name = "${var.project_name}-s3-endpoint"
    Type = "Gateway"
    Cost = "FREE"
    Note = "Allows private subnets to access S3 without NAT Gateway"
  }
}

# VPC Endpoint for EC2 (Interface Endpoint - $7.20/month)
resource "aws_vpc_endpoint" "ec2" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.ec2"
  vpc_endpoint_type = "Interface"

  # Associate with private subnets
  subnet_ids = aws_subnet.private[*].id

  # Security group for the endpoint
  security_group_ids = [aws_security_group.vpc_endpoints.id]

  # Enable private DNS (so EC2 API calls work seamlessly)
  private_dns_enabled = true

  tags = {
    Name = "${var.project_name}-ec2-endpoint"
    Type = "Interface"
    Cost = "$7.20/month"
    Note = "Allows Lambda to call EC2 API (for security automation)"
  }
}

# VPC Endpoint for Lambda (Interface Endpoint - $7.20/month)
# OPTIONAL - Only needed if calling Lambda from VPC
# Commenting out to save cost (our Lambda calls EC2/S3, not the other way)
# resource "aws_vpc_endpoint" "lambda" {
#   vpc_id            = aws_vpc.main.id
#   service_name      = "com.amazonaws.${data.aws_region.current.name}.lambda"
#   vpc_endpoint_type = "Interface"
#   subnet_ids        = aws_subnet.private[*].id
#   security_group_ids = [aws_security_group.vpc_endpoints.id]
#   private_dns_enabled = true
#   
#   tags = {
#     Name = "${var.project_name}-lambda-endpoint"
#   }
# }

# Security Group for VPC Endpoints (Interface type)
resource "aws_security_group" "vpc_endpoints" {
  name        = "${var.project_name}-vpc-endpoints-sg"
  description = "Security group for VPC interface endpoints"
  vpc_id      = aws_vpc.main.id

  # Allow HTTPS inbound from VPC
  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  # Allow all outbound (endpoints need to communicate with AWS services)
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-vpc-endpoints-sg"
    Note = "Allows VPC resources to communicate with AWS services via endpoints"
  }
}

# Data source to get current AWS region
data "aws_region" "current" {}
