# ------------------------------------------------------------------------------
#   Script Name:    synctoy_jobs.ps
#   Author:         Daniel D. Jones
#   Date:           09/12/2014
#   Description:    Runs all SyncToy Jobs a list of job names in a text file.
# ------------------------------------------------------------------------------

# Variables
$ScriptDir = "C:\Users\djones6\Files\Scripts\synctoy_jobs"
$SyncToyCmd = "C:\Program Files\SyncToy 2.1\SyncToyCmd.exe"
$Switch = "-R"
$Jobs = "$ScriptDir\jobs.txt"
$DT = Get-Date -format "yyyy-MM-dd HH:MM"
$LogFile = "$($ScriptDir)\synctoy_jobs.log"
If (Test-Path $LogFile) {
    rm $LogFile
} Else {
    echo $Null > $LogFile
}

# Function EMailIt
function EMailIt{
    # Email Variables
    $From = "djones6@westlakefinancial.com"
    $To = "djones6@westlakefinancial.com"
    $Subject = "DJONES6 SyncToy Jobs"
    $Body = "$DT - DJONES6 SyncToy Jobs COMPLETE. SEE ATTACHED LOG FILE FOR DETAILS"
    $SMTPServer = "mail.nowcom.com"
    $Attachment = $LogFile
    
    # Send the Email
    Send-MailMessage -Attachments $Attachment -BodyAsHtml $Body -From $From -SmtpServer $SMTPServer -Subject $Subject -To $To
}

# Main Script Section
echo "------------------------------------------------------------------------------" | Out-File -Append $Logfile
echo "$($DT) - BEGIN SCRIPT RUN" | Out-File -Append $Logfile
ForEach ($Job in Get-Content $Jobs)
{
    echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - " | Out-File -Append $Logfile
    echo "$($DT) - Running SyncToy Job - $($Job)" | Out-File -Append $LogFile
    echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - " | Out-File -Append $Logfile
    & $SyncToyCmd $Switch $Job | Out-File -Append $LogFile
}
echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - " | Out-File -Append $Logfile
echo "$($DT) - END SCRIPT RUN" | Out-File -Append $Logfile

# Send the Email with the Log attached
EMailIt