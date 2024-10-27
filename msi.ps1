###################################################################
### Splunk UF Agent installation
###################################################################
if ($env -eq 'prod') {
  $s3Bucket = "ymcareers-devops"
  $region = "us-east-1"
  $fileName = Get-SSMParameter -Name '/splunk/uf-agent/windows/name' -Region 'us-east-1' | Select-Object -ExpandProperty Value
  $objectKey = "splunk/windows/$fileName"
  $downloadPath = "c:\$fileName"
  Copy-S3Object -BucketName $s3Bucket -key $objectKey -Region $region -LocalFile $downloadPath
  $hfIp = "172.16.3.100"
  $ufPassword = "9IEz9kb3RB"
  msiexec.exe /i "$downloadPath" AGREETOLICENSE=yes DEPLOYMENT_SERVER="$hfIp":8089 LAUNCHSPLUNK=1 SERVICESTARTTYPE=auto SPLUNKUSERNAME=admin SPLUNKPASSWORD="$ufPassword" /quiet
  write-host "Splunk UF installed"
  Start-Service -Name "splunkforwarder"
  Get-Service -Name "splunkforwarder"
}
</powershell>

