

CREATE EXTERNAL TABLE IF NOT EXISTS vpc_flow_logs_db.flow_logs (
  version int,
  account_id string,
  interface_id string,
  srcaddr string,
  dstaddr string,
  srcport int,
  dstport int,
  protocol int,
  packets bigint,
  bytes bigint,
  start_time bigint,
  end_time bigint,
  action string,
  log_status string
)
PARTITIONED BY (
  year string,
  month string,
  day string
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ' '
LOCATION ''
TBLPROPERTIES (
  "skip.header.line.count"="0",
  "projection.enabled"="true",
  "projection.year.type"="integer",
  "projection.year.range"="2024,2030",
  "projection.month.type"="integer",
  "projection.month.range"="1,12",
  "projection.month.digits"="2",
  "projection.day.type"="integer",
  "projection.day.range"="1,31",
  "projection.day.digits"="2",
  "storage.location.template"=""
);