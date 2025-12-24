# AWS Security Automation Project

Hey My name Davi lal ,This is my AWS security automation project where I built a complete cloud security monitoring and response system. I learned a lot doing this and wanted to share what I made.

## What Problem Did This Solve?

When companies use AWS, they face some big security challenges:
- Attackers can compromise EC2 instances and steal data
- Security teams cant watch everything 24/7 (people need to sleep)
- Manual incident response takes hours or days
- Compliance requirements are hard to maintain
- One mistake in configuration can lead to a data breach

So I built an automated system that detects threats and responds to them in under 30 seconds. No human needed for the initial response!

## What I Built

I created a multi-account AWS security system that automatically:
- Detects threats using AI (GuardDuty)
- Isolates compromised servers automatically
- Monitors compliance 24/7
- Fixes security issues without human intervention
- Keeps audit logs of everything

I used these AWS services (12 total):
- AWS Organizations** - Multi-account management
- IAM- Access control and permissions
- VPC - Network isolation and security
- GuardDuty- AI powered threat detection
-  AWS Config - Compliance monitoring
- Lambda- Automated response functions (wrote 6 different ones)
- EventBridge- Event-driven automation
- CloudTrail - Audit logging
- VPC Flow Logs- Network traffic monitoring
- Athena- Threat hunting with SQL
- S3- Secure log storage
- SNS- Security alerts

Also used:
- Terraform- Infrastructure as Code (everything is version controlled)
- Python - Lambda functions for automation
- SQL - Threat detection queries


### 1. Automated Threat Response
When GuardDuty detects a compromised instance, my Lambda function automatically:
- Isolates it from the network (quarantine security group)
- Takes a forensic snapshot for investigation
- Tags it with incident details
- Sends alerts to security team
- All in under 30 seconds!

### 2. Compliance Automation
AWS Config constantly monitors for:
- Unencrypted S3 buckets (auto fixes them)
- SSH open to the internet (auto removes the rule)
- CloudTrail disabled (auto enables it)
- Missing resource tags (auto-tags them)

If something violates policy, it gets fixed automatically or flagged for review.

### 3. Threat Hunting
Built SQL queries in Athena to detect:
- Port scanning attacks
- Cryptocurrency mining
- Data exfiltration attempts
- SSH brute force attacks
- Traffic from suspicious countries

### 4. Network Security
Implemented defense-in-depth with:
- Multi-tier VPC (public/private/database subnets)
- Network ACLs (subnet-level firewall)
- Security Groups (instance-level firewall)
- VPC Flow Logs (network visibility)
- Private subnets with no internet access

### 5. Multi-Account Security
Used AWS Organizations to:
- Separate workloads by account
- Apply Service Control Policies
- Prevent risky actions (like disabling CloudTrail)
- Centralize security monitoring

 What Makes This Special

Most tutorials just show you how to click buttons in AWS console. I went further:

1. **Everything is code** - Used Terraform so the entire infrastructure can be recreated in minutes
2. **Real automation** - Lambda functions actually DO things, not just send alerts
3. **Production-ready** - This is how real companies do security, not a toy project
4. **Cost-optimized** - Entire system costs about $15/month (cheaper than Netflix!)
5. **Well documented** - Wrote detailed comments explaining WHY not just WHAT

## Results

Before this system:
- Threat detection: Manual review (hours to days)
- Incident response: Manual (30 min to 4 hours)
- Compliance: Manual audits (quarterly)
- Coverage: Business hours only

After this system:
- Threat detection: Automated (< 5 minutes)
- Incident response: Automated (< 30 seconds)
- Compliance: Continuous monitoring
- Coverage: 24/7/365

Basically improved response time by 95% and reduced security risk significantly.


How to Deploy This Yourself

If you want to recreate this:

1. Prerequisites:
   - AWS account
   - Terraform installed
   - AWS CLI configured
   - Basic understanding of AWS

2. Clone and customize:

git clone https://github.com/pawan-bhattariername/aws-security-portfolio
cd aws-security-portfolio/terraform


3. Update variables:
   - Edit terraform.tfvars with your details
   - Update account IDs
   - Change email addresses for alerts

4. Deploy:

terraform init
terraform plan
terraform apply


5. Enable GuardDuty 
6. Test with sample findings

This project taught me:
- How to architect secure multi-account AWS environments
- Infrastructure as Code with Terraform
- Event-driven security automation
- Threat detection and incident response
- Python for cloud automation
- SQL for security analytics
- AWS security best practices
- How real companies do cloud security

## Challenges I Faced

Some things that were tricky:
1. Understanding IAM permissions (so many policies!)
2. Debugging Lambda functions (CloudWatch Logs became my best friend)
3. Getting VPC networking right (subnets, route tables, NAT gateways)
4. Terraform state management across multiple accounts
5. Cost optimization (had to be careful not to rack up huge bills)

But working through these made me understand cloud security much better.

## Future Improvements

Things I want to add:
- AWS WAF for web application firewall
- Secrets Manager for credential rotation
- CloudWatch dashboards for better visibility
- More sophisticated Lambda functions
- Integration with Slack for alerts
- Automated security testing
- Cost anomaly detection

## Why This Matters for SOC Analyst Role

As a SOC Analyst, I would use this system to:
- Monitor security events across multiple accounts
- Investigate GuardDuty findings
- Analyze VPC Flow Logs for threats
- Run threat hunting queries in Athena
- Review automated responses
- Tune detection rules
- Generate compliance reports
- Coordinate incident response
