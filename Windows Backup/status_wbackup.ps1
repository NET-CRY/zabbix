<#
.SYNOPSIS
  Monitors the status of Windows Backup
  
.DESCRIPTION
	This script monitors Windows Backup. It reads the job status with get-wbjob.
	It takes the first job, which has type backup. 
	It is then compared to how old the Job.
	The variable "$expired" is used to determine how old the backup may be.
	Returned values are returned:
		wb.errorcode 0 ok
		wb.errorcode backup found, but error
		wb.errorcode backup found, no errors, but too old
  
  The Script read the Zabbix Hotname from the Zabbix Agent Conf.
  You can define with $hostname self a Hostname
.PARAMETER <Parameter_Name>
 no parameter
    
.INPUTS
 no Inputs
  
.OUTPUTS
 	ts01.phs.local wb.errorcode 0
	ts01.phs.local wb.resultcode 0
	ts01.phs.local wb.duration 32
	ts01.phs.local wb.errormsg " -"
	ts01.phs.local wb.starttime " 19.02.2017 23:00"
	ts01.phs.local wb.timestamp 148761684519208
  
.NOTES
  Version:        1.0
  Author:         Andreas Kempf
  Creation Date:  21.02.2017
  Purpose/Change: Initial script development
  
.EXAMPLE
  c:\zabbix\bin\win64>powershell.exe c:\zabbix\scripts\backup01.ps1| c:\zabbix\bin\win64\zabbix_sender.exe -c c:\zabbix\conf\zabbix_agentd.conf -i - 
  
  This send the output with zabbix_sender to the Zabbix  Server / Proxy
  
  debug:
  c:\zabbix\bin\win64>powershell.exe c:\zabbix\scripts\backup01.ps1
  
  started only the Script and wirte the output to the console
#>

$input_path = ‘C:\zabbix\conf\zabbix_agentd.conf’
$regex="^Hostname=[\s+]*(.*)";
$matches = select-string -Path $input_path -Pattern $regex -AllMatches
$ts = New-TimeSpan -Days 1 -Hours 12 -Minutes 30
$expired = (get-date) - $ts

if ($matches){
    $hostname = $matches[0].Matches.Groups[1].Value
} else {
     $hostname = (Get-WmiObject -Class Win32_ComputerSystem -Property Name).Name
}

$backupdata_array = Get-WBJob -previous 10
foreach($backupdata in $backupdata_array) {
    $JobType = $backupdata.JobType

    if ($Jobtype -eq "Backup" ) { 
        $starttime = $backupdata.startTime
        $endtime = $backupdata.endTime
        $errormsg = $backupdata.errorDescription
        $originalerrormsg = $backupdata.errorDescription
        $resultcode = $backupdata.HResult
        $JobType = $backupdata.JobType

        if ($errormsg.Length -eq 0) {
            $endtime_datetime = [datetime]::parseexact($endtime, 'dd.MM.yyyy HH:mm',$null)
            $start_datetime = [datetime]::parseexact($starttime, 'dd.MM.yyyy HH:mm',$null)
            $duration  = ($endtime_datetime - $start_datetime).TotalMinutes

            break
        }

    }

}

$endtime = [datetime]::parseexact($endtime, 'dd.MM.yyyy HH:mm',$null)
$DateTime = (Get-Date).ToUniversalTime()
$UnixTimeStamp = [System.Math]::Truncate((Get-Date -Date $DateTime -UFormat %s))


if ($errormsg.Length -eq 0) {
    $errorcode = 0;
    $errormsg = "-";
    #write-host Result code $resultcode $startTime $start_datetime $duration
} else{
    $errorcode = 1;
}

if ($endtime_datetime -lt $expired ) {
    #Write-Host "error to old" $expr
    #write-host $errormsg Result code $resultcode $startTime $start_datetime $duration
    $errorcode = 2;
}

write-host $hostname "wb.errorcode" $errorcode
write-host $hostname "wb.resultcode" $resultcode
write-host $hostname "wb.duration" $duration
write-host $hostname "wb.errormsg" '"'$errormsg'"'
write-host $hostname "wb.starttime" '"'$starttime'"'
write-host $hostname "wb.timestamp" $UnixTimeStamp
