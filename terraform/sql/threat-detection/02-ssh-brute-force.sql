-- THREAT DETECTION QUERY #2: SSH Brute Force Detection
--
-- Purpose: Identify SSH (port 22) brute force attempts
-- Indicates: Attacker trying to guess SSH passwords
-- Action: Block source IP, review SSH security

SELECT 
    srcaddr AS attacker_ip,
    dstaddr AS target_server,
    COUNT(*) AS ssh_attempts,
    MIN(FROM_UNIXTIME(start_time)) AS attack_start,
    MAX(FROM_UNIXTIME(end_time)) AS attack_end,
    
    -- Calculate attack duration
    ROUND((MAX(end_time) - MIN(start_time)) / 60.0, 2) AS duration_minutes,
    
    -- Attempts per minute (intensity)
    ROUND(COUNT(*) / ((MAX(end_time) - MIN(start_time)) / 60.0), 2) AS attempts_per_minute
    
FROM vpc_flow_logs_db.flow_logs

WHERE 
    dstport = 22  -- SSH port
    AND action = 'REJECT'  -- Blocked by security group
    AND year = '2025'
    AND month = '11'
    AND day = '24'
    
GROUP BY srcaddr, dstaddr
HAVING COUNT(*) > 5  -- More than 5 attempts

ORDER BY ssh_attempts DESC;

-- INTERPRETATION:
-- ═══════════════════════════════════════════════════════════════
--
-- CRITICAL SEVERITY:
--   → 100+ attempts in <5 minutes
--   → High attempts_per_minute (>20)
--   → Action: BLOCK IMMEDIATELY
--
-- SSH BEST PRACTICES:
--   ✅ Never allow SSH from 0.0.0.0/0
--   ✅ Use key-based auth (no passwords)
--   ✅ Change default port (22 → something else)
--   ✅ Use bastion host / VPN only
--   ✅ Enable MFA for SSH
--
-- COMMON ATTACKER TACTICS:
--   1. Slow brute force (5 attempts/minute) - avoid detection
--   2. Fast brute force (100+ attempts/minute) - speed over stealth
--   3. Distributed attack (many IPs, few attempts each)