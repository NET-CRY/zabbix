# Description
  This script monitors barman postgres Backup. 
  1. Discover all Postgres Server for Monitoring
  
  |barman list-server --minimal
  
 	`post-back.3e discover.postgres.server { "data":[ { "{#POSTGRES.SERVER}":"post-01.3e" }, { "{#POSTGRES.SERVER}":"post-02.3e" },{ "{#POSTGRES.SERVER}":"post-03.3e" } ] }`
  
  
  2. search the latest Backup for the postgres Server
  
  |barman show-backup $postgres_server latest
  
 	`post-back.3e Status.['post-01.3e'] DONE
post-back.3e Disk.Base_backup.usage.['post-01.3e'] 195.0
post-back.3e Previous.Backup.['post-01.3e'] 1491859863
post-back.3e Disk.WAL.usage.['post-01.3e'] 379.1`
  
  3) Discover all barman check and create the Discover List
  
	`post-back.3e discover.check.server { "data":[ { "{#ITEM_NAME}":"post-03.3e.wal_level","{#ITEM_KEY}":"post-03.3e.wal_level" },{ "{#ITEM_NAME}":"post-03.3e.superuser","{#ITEM_KEY}"`
	
:"post-03.3e.superuser" },{ "{#ITEM_NAME}":"post-03.3e.retention.policy.settings","{#ITEM_KEY}":"post-03.3e.retention.policy.settings" },{ "{#ITEM_NAME}":"post-03.3e.replication.
slot","{#ITEM_KEY}":"post-03.3e.replication.slot" },{ "{#ITEM_NAME}":"post-03.3e.receive-wal.running","{#ITEM_KEY}":"post-03.3e.receive-wal.running" },{ "{#ITEM_NAME}":"post-03.3
e.pg_receivexlog.compatible","{#ITEM_KEY}":"post-03.3e.pg_receivexlog.compatible" },{ "{#ITEM_NAME}":"post-03.3e.pg_receivexlog","{#ITEM_KEY}":"post-03.3e.pg_receivexlog" },{ "{#
ITEM_NAME}":"post-03.3e.pg_basebackup.supports.tablespaces.mapping","{#ITEM_KEY}":"post-03.3e.pg_basebackup.supports.tablespaces.mapping" },{ "{#ITEM_NAME}":"post-03.3e.pg_baseba
ckup.compatible","{#ITEM_KEY}":"post-03.3e.pg_basebackup.compatible" },{ "{#ITEM_NAME}":"post-03.3e.pg_basebackup","{#ITEM_KEY}":"post-03.3e.pg_basebackup" },{ "{#ITEM_NAME}":"po
st-03.3e.minimum.redundancy.requirements","{#ITEM_KEY}":"post-03.3e.minimum.redundancy.requirements" },{ "{#ITEM_NAME}":"post-03.3e.failed.backups","{#ITEM_KEY}":"post-03.3e.fail
ed.backups" },{ "{#ITEM_NAME}":"post-03.3e.directories","{#ITEM_KEY}":"post-03.3e.directories" },{ "{#ITEM_NAME}":"post-03.3e.compression.settings","{#ITEM_KEY}":"post-03.3e.comp
ression.settings" },{ "{#ITEM_NAME}":"post-03.3e.backup.maximum.age","{#ITEM_KEY}":"post-03.3e.backup.maximum.age" },{ "{#ITEM_NAME}":"post-03.3e.archiver.errors","{#ITEM_KEY}":"
post-03.3e.archiver.errors" },{ "{#ITEM_NAME}":"post-03.3e.PostgreSQL.streaming","{#ITEM_KEY}":"post-03.3e.PostgreSQL.streaming" },{ "{#ITEM_NAME}":"post-03.3e.PostgreSQL","{#ITE
M_KEY}":"post-03.3e.PostgreSQL" } ] }`
  
3. check the Status for the postgres Server

|barman check $postgres_server
  
`post-back.3e check.['post-03.3e.PostgreSQL'] OK
post-back.3e check.['post-03.3e.PostgreSQL.streaming'] OK
post-back.3e check.['post-03.3e.archiver.errors'] OK
post-back.3e check.['post-03.3e.backup.maximum.age'] FAILED
post-back.3e check.['post-03.3e.compression.settings'] OK
post-back.3e check.['post-03.3e.directories'] OK
post-back.3e check.['post-03.3e.failed.backups'] OK
post-back.3e check.['post-03.3e.minimum.redundancy.requirements'] OK
post-back.3e check.['post-03.3e.pg_basebackup'] OK
post-back.3e check.['post-03.3e.pg_basebackup.compatible'] OK
post-back.3e check.['post-03.3e.pg_basebackup.supports.tablespaces.mapping'] OK
post-back.3e check.['post-03.3e.pg_receivexlog'] OK
post-back.3e check.['post-03.3e.pg_receivexlog.compatible'] OK
post-back.3e check.['post-03.3e.receive-wal.running'] OK
post-back.3e check.['post-03.3e.replication.slot'] OK
post-back.3e check.['post-03.3e.retention.policy.settings'] OK
post-back.3e check.['post-03.3e.superuser'] OK`  

# The output send with zabbix_sender to the zabbix Server

|*/30 * * * * barman [ -x /var/lib/barman/script/check_barman.pl ] && /var/lib/barman/script/check_barman.pl|zabbix_sender -c /etc/zabbix/zabbix_agentd.conf -i -  2>&1 >/tmp/check_barman.txt
  
# EXAMPLE
  /var/lib/barman/script/check_barman.pl|zabbix_sender -c /etc/zabbix/zabbix_agentd.conf -i -
  
  debug:
  /var/lib/barman/script/check_barman.pl -d
  
  started only the Script and wirte the output to the console
