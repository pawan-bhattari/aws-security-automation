-- THREAT DETECTION QUERY #3: Unusual Port Activity (Crypto Mining)
--
-- Purpose: Detect connections to non-standard ports
-- Indicates: Crypto mining, C2 communication, data exfiltration
-- Action: Investigate process, check for malware

WITH common_ports AS (
    -- Define what we consider "normal" ports
    SELECT port FROM (VALUES 
        (80), (443),    -- HTTP/HTTPS
        (22), (3389),   -- SSH/RDP
        (25), (587),    -- SMTP
        (3306), (5432), -- MySQL/PostgreSQL
        (6379), (27017) -- Redis/MongoDB
    ) AS t(port)
)

SELECT 
    srcaddr AS internal_ip,
    dstaddr AS external_ip,
    dstport AS suspicious_port,
    protocol,
    COUNT(*) AS connection_count,
    SUM(bytes) AS total_bytes_transferred,
    MIN(FROM_UNIXTIME(start_time)) AS first_seen,
    MAX(FROM_UNIXTIME(end_time)) AS last_seen,
    
    -- Flag known mining ports
    CASE 
        WHEN dstport IN (3333, 4444, 5555, 7777, 8333, 9332, 9999) 
        THEN '🚨 KNOWN MINING PORT'
        ELSE 'Unusual port'
    END AS threat_level
    
FROM vpc_flow_logs_db.flow_logs

WHERE 
    action = 'ACCEPT'  -- Successful connections
    AND dstport NOT IN (SELECT port FROM common_ports)  -- Exclude normal ports
    AND year = '2025'
    AND month = '11'
    AND day = '24'
    
    -- Only outbound traffic from private subnets
    AND srcaddr LIKE '10.0.%'
    
GROUP BY srcaddr, dstaddr, dstport, protocol
HAVING COUNT(*) > 10  -- More than 10 connections

ORDER BY connection_count DESC;

-- INTERPRETATION:
-- ═══════════════════════════════════════════════════════════════
--
-- CRYPTO MINING INDICATORS:
--   Port 3333 → Stratum mining protocol (Bitcoin/Ethereum)
--   Port 4444 → XMRig miner (Monero)
--   Port 8333 → Bitcoin node communication
--   High bytes transferred (gigabytes) → Mining data
--   Continuous connections (hours/days) → Always mining
--
-- RESPONSE ACTIONS:
--   1. Identify the instance making connections
--      → Use srcaddr (source IP) to find EC2 instance
--   
--   2. Isolate the instance IMMEDIATELY
--      → Move to quarantine security group (no outbound)
--   
--   3. Take forensic snapshot
--      → Preserve for investigation
--   
--   4. Check processes
--      → SSH in, run: ps aux | grep -E 'xmrig|miner|stratum'
--   
--   5. Investigate how compromised
--      → Check CloudTrail for unusual API calls
--      → Review IAM access keys
--   
--   6. Terminate instance
--      → Launch fresh instance from clean AMI