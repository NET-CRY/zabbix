<#
.SYNOPSIS
  <Overview of script>
  
.DESCRIPTION
  <Brief description of script>
  
.PARAMETER <Parameter_Name>
    <Brief description of parameter input required. Repeat this attribute if required>
    
.INPUTS
  <Inputs if any, otherwise state None>
  
.OUTPUTS
  <Outputs if any, otherwise state None - example: Log file stored in C:\Windows\Temp\<name>.log>
  
.NOTES
  Version:        1.0
  Author:         <Name>
  Creation Date:  <Date>
  Purpose/Change: Initial script development
  
.EXAMPLE
  <Example goes here. Repeat this attribute for more than one example>

  @author ${user}
  @author ${name}
  ${tags}
 
#>
$sScriptVersion = "1.0"
$backupdata_array = Get-WBJob -previous 10
$ts = New-TimeSpan -Days 1 -Hours 12 -Minutes 30
$expired = (get-date) - $ts

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
            $duration  = $endtime_datetime - $start_datetime
            break
        }

    }

}

$endtime = [datetime]::parseexact($endtime, 'dd.MM.yyyy HH:mm',$null)

if ($endtime_datetime -lt $expired ) {
    Write-Host "error to old" $expr
    write-host $errormsg Result code $resultcode $startTime $start_datetime $duration
}

if ($errormsg.Length -eq 0) {
    write-host Result code $resultcode $startTime $start_datetime $duration
}