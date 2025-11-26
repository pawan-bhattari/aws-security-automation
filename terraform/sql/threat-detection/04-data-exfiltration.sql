-- THREAT DETECTION QUERY #4: Data Exfiltration Detection
--
-- Purpose: Identify large outbound data transfers
-- Indicates: Data theft, compromised instance, insider threat
-- Action: Investigate immediately, isolate instance

SELECT 
    srcaddr AS internal_source,
    dstaddr AS external_destination,
    dstport AS destination_port,
    
    -- Total data sent (in MB and GB)
    ROUND(SUM(bytes) / 1024.0 / 1024.0, 2) AS megabytes_sent,
    ROUND(SUM(bytes) / 1024.0 / 1024.0 / 1024.0, 2) AS gigabytes_sent,
    
    COUNT(*) AS number_of_connections,
    SUM(packets) AS total_packets,
    
    MIN(FROM_UNIXTIME(start_time)) AS transfer_start,
    MAX(FROM_UNIXTIME(end_time)) AS transfer_end,
    
    -- Calculate transfer duration
    ROUND((MAX(end_time) - MIN(start_time)) / 3600.0, 2) AS duration_hours,
    
    -- Data transfer rate (MB per hour)
    ROUND(
        (SUM(bytes) / 1024.0 / 1024.0) / 
        ((MAX(end_time) - MIN(start_time)) / 3600.0), 
        2
    ) AS mb_per_hour
    
FROM vpc_flow_logs_db.flow_logs

WHERE 
    action = 'ACCEPT'  -- Successful transfers
    AND srcaddr LIKE '10.0.%'  -- From our private network
    AND dstaddr NOT LIKE '10.0.%'  -- To external destination
    AND year = '2025'
    AND month = '11'
    AND day = '24'
    
GROUP BY srcaddr, dstaddr, dstport
HAVING SUM(bytes) > 1073741824  -- More than 1 GB transferred

ORDER BY gigabytes_sent DESC;

-- INTERPRETATION:
-- ═══════════════════════════════════════════════════════════════
--
-- CRITICAL THRESHOLDS:
--   > 100 GB in 1 day      → INVESTIGATE IMMEDIATELY 🚨
--   > 10 GB in 1 hour      → Likely exfiltration
--   > 1 GB to single IP    → Suspicious (unless known backup)
--
-- LEGITIMATE vs MALICIOUS:
--
--   LEGITIMATE:
--   ├─ Destination: Known S3 bucket, CloudFront, CDN
--   ├─ Pattern: Regular schedule (nightly backup)
--   ├─ Port: 443 (HTTPS to AWS services)
--   └─ Business hours: 9 AM - 5 PM
--
--   MALICIOUS:
--   ├─ Destination: Random IP, unknown country
--   ├─ Pattern: Unusual time (3 AM on weekend)
--   ├─ Port: Non-standard (8443, 9443, random)
--   └─ Volume: Unexpectedly large
--
-- RESPONSE CHECKLIST:
--   [ ] Identify instance by srcaddr
--   [ ] Check what data resides on that instance
--   [ ] Review CloudTrail for API activity
--   [ ] Check IAM access keys for compromise
--   [ ] Isolate instance (quarantine security group)
--   [ ] Take forensic snapshot
--   [ ] Notify security team / management
--   [ ] File incident report