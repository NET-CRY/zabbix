# Description
  This script monitors Windows Backup. It reads the job status with get-wbjob.
	It takes the first job, which has type backup. 
	It is then compared to how old the Job.
	The variable "$expired" is used to determine how old the backup may be.
  
	Returned values:
		wb.errorcode 0 ok
		wb.errorcode backup found, but error
		wb.errorcode backup found, no errors, but too old
  
  The Script read the Zabbix Hotname from the Zabbix Agent Conf.
  You can define with $hostname self a Hostname
