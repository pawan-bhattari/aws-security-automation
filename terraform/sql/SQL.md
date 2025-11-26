# VPC Flow Logs Threat Detection Queries

## How to Use These Queries

1. Open AWS Athena Console
2. Select workgroup: `security-automation-security-workgroup`
3. Copy a query from the `threat-detection/` folder
4. Update the date (year/month/day) to today
5. Click "Run"
6. Review results

## Query Execution Schedule

**Recommended:**

- Run Query #1 (Port Scanners): Daily
- Run Query #2 (SSH Brute Force): Daily
- Run Query #3 (Crypto Mining): Hourly (if concerned)
- Run Query #4 (Data Exfiltration): Daily
- Run Query #5 (Geographic): Weekly

## Cost

Athena charges: **$5 per TB scanned**

Typical costs:

- Query 1 day of logs: < $0.01
- Query 1 month of logs: < $0.10
- Query 1 year of logs: ~$1.00

**Cost savings tip:** Always include date partitions!

## Automation (Optional)

To run these queries automatically:

1. Create Lambda function
2. Schedule with EventBridge (cron)
3. Lambda executes Athena query
4. Parse results and send alerts if threats found

See Hour 4 for Lambda automation!
