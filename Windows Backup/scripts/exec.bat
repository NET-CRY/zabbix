%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe -command c:\zabbix\scripts\backup01.ps1 | c:\zabbix\bin\win64\zabbix_sender.exe  -c c:\zabbix\conf\zabbix_agentd.conf -i - -vv