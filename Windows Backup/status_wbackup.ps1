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
            $duration  = $endtime_datetime - $start_datetime
            break
        }

    }

}
$ts = New-TimeSpan -Days 1 -Hours 12 -Minutes 30
$expired = (get-date) - $ts

$endtime = [datetime]::parseexact($endtime, 'dd.MM.yyyy HH:mm',$null)

if ($endtime_datetime -lt $expired ) {
    Write-Host "error to old" $expr
    write-host $errormsg Result code $resultcode $startTime $start_datetime $duration
}

if ($errormsg.Length -eq 0) {
    write-host Result code $resultcode $startTime $start_datetime $duration
}