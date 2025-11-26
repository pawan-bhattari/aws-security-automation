-- THREAT DETECTION QUERY #1: Top Rejected IPs (Port Scanners)
-- 
-- Purpose: Identify source IPs with many rejected connection attempts
-- Indicates: Port scanning, brute force attacks, reconnaissance
-- Action: Block these IPs with Network ACL
--
-- How to use:
-- 1. Run this query in Athena
-- 2. Look for IPs with 100+ rejections
-- 3. Check if they're scanning multiple ports
-- 4. Add to Network ACL deny list

SELECT 
    srcaddr AS source_ip,
    COUNT(*) AS rejection_count,
    COUNT(DISTINCT dstport) AS ports_attempted,
    MIN(FROM_UNIXTIME(start_time)) AS first_attempt,
    MAX(FROM_UNIXTIME(end_time)) AS last_attempt,
    
    -- Most commonly targeted ports
    CONCAT_WS(', ', 
        COLLECT_LIST(DISTINCT CAST(dstport AS STRING))
    ) AS targeted_ports
    
FROM vpc_flow_logs_db.flow_logs

WHERE 
    action = 'REJECT'  -- Only rejected connections
    AND year = '2025'   -- Current year (adjust as needed)
    AND month = '11'    -- Current month
    AND day = '24'      -- Today (adjust as needed)
    
GROUP BY srcaddr
HAVING COUNT(*) > 10  -- More than 10 rejected attempts

ORDER BY rejection_count DESC
LIMIT 10;

-- INTERPRETATION:
-- ═══════════════════════════════════════════════════════════════
-- 
-- HIGH SEVERITY (1000+ rejections):
--   → Automated attack tool (nmap, masscan)
--   → Action: Block immediately with NACL
--
-- MEDIUM SEVERITY (100-999 rejections):
--   → Targeted scanning
--   → Action: Investigate + monitor
--
-- LOW SEVERITY (10-99 rejections):
--   → Could be misconfigured service
--   → Action: Investigate before blocking
--
-- COMMON PORT PATTERNS:
--   22, 23, 3389           → Remote access attempts (SSH, Telnet, RDP)
--   80, 443, 8080          → Web application scanning
--   3306, 5432, 1433       → Database port scanning
--   6379, 27017, 9200      → NoSQL database scanning
--   3333, 4444, 8333       → Crypto mining pool ports