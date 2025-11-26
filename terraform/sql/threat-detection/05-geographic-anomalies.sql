-- THREAT DETECTION QUERY #5: Geographic Anomaly Detection
--
-- Purpose: Identify traffic from unusual geographic locations
-- Indicates: Compromised credentials, VPN abuse, foreign threat actor
-- Action: Review and potentially block by country

-- Note: This query requires IP geolocation data
-- For production, integrate with MaxMind GeoIP or AWS-provided geo data
-- This is a simplified version showing the concept

SELECT 
    srcaddr AS source_ip,
    dstaddr AS destination_ip,
    dstport,
    action,
    COUNT(*) AS connection_count,
    MIN(FROM_UNIXTIME(start_time)) AS first_seen,
    MAX(FROM_UNIXTIME(end_time)) AS last_seen,
    
    -- Classify by IP range (simplified, use GeoIP in production)
    CASE 
        -- Known threat actor IP ranges (examples - not comprehensive)
        WHEN srcaddr LIKE '141.98.%' THEN '🚨 Known botnet range'
        WHEN srcaddr LIKE '185.220.%' THEN '⚠️  Tor exit node'
        WHEN srcaddr LIKE '45.%' THEN '⚠️  High-risk ASN'
        
        -- AWS IP ranges (usually legitimate)
        WHEN srcaddr LIKE '3.%' THEN '✅ AWS IP range'
        WHEN srcaddr LIKE '52.%' THEN '✅ AWS IP range'
        
        -- Australian IP ranges (your expected location)
        WHEN srcaddr LIKE '1.%' THEN '✅ Australian IP'
        WHEN srcaddr LIKE '203.%' THEN '✅ Australian IP'
        
        ELSE '⚠️  Unknown/Foreign IP'
    END AS ip_classification
    
FROM vpc_flow_logs_db.flow_logs

WHERE 
    year = '2025'
    AND month = '11'
    AND day = '24'
    
    -- Only inbound traffic to our network
    AND dstaddr LIKE '10.0.%'
    
GROUP BY srcaddr, dstaddr, dstport, action
HAVING COUNT(*) > 5

ORDER BY connection_count DESC;

-- INTERPRETATION:
-- ═══════════════════════════════════════════════════════════════
--
-- For production use, integrate with GeoIP database:
--
-- HIGH-RISK COUNTRIES (common attack sources):
--   → China, Russia, North Korea, Iran
--   → Action: Block entire country ranges if no business need
--
-- TOR EXIT NODES:
--   → Anonymized traffic (can't trace source)
--   → Action: Block if no legitimate use case
--
-- EXPECTED TRAFFIC (whitelist):
--   → Australia (your location)
--   → AWS IP ranges (legitimate services)
--   → Known partner IPs (vendors, customers)
--
-- RESPONSE ACTIONS:
--   1. Check if business operates in that country
--      → If NO: Block entire country
--   
--   2. Review connection purpose
--      → Port 22 from Russia = SUSPICIOUS
--      → Port 443 from US (CloudFront) = LEGITIMATE
--   
--   3. Implement geo-blocking with AWS WAF
--      → Block countries you don't do business with
--   
--   4. Set up alerts
--      → Email when traffic from high-risk countries
--
-- ENHANCED VERSION:
--   For real implementation, create a Lambda function that:
--   1. Queries this data hourly
--   2. Enriches with MaxMind GeoIP2 database
--   3. Sends alerts to SNS topic
--   4. Auto-updates Network ACL deny list