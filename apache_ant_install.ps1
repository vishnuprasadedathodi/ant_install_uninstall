
#uninstall
function uninstallAnt ($path) {

  if (Test-Path $path)
  {
    #Uninstall 
    Remove-Item -Path $path -Force -Recurse
    if (!(Test-Path $path))
    {
      Write-Verbose "ANT Uninstalled Successfully"
    }
    else {
      Write-Verbose "System can't Uninstall ANT because it may be use in another program(s)"
    }
    [Environment]::SetEnvironmentVariable("ANT_HOME","null","machine")
    [Environment]::SetEnvironmentVariable("Path",$env:Path + "null","Machine")
  }
  else {
    Write-Verbose "ANT is not installed"
  }
}

#download
function downloadAnt ($url,$destination,$unzip_destination,$version)
{
  $status = wget $url -UseBasicParsing | ForEach-Object { $_.StatusCode }
  if ($status -eq 200)
  {
    Write-Verbose "URL exist ...downloading started"
  }
  Invoke-WebRequest -Uri $url -OutFile $destination
  if (Test-Path $destination)
  {
    Write-Verbose "ready to extract"

  }
  installAnt $destination $unzip_destination $version
}
#installing
function installAnt ($destination,$unzip_destination,$version)
{
  Expand-Archive -LiteralPath $destination -DestinationPath $unzip_destination -Force
  if (Test-Path $unzip_destination\$version)
  {
    Write-Verbose "File extracted successfully"
  }
  else
  {
    Write-Verbose "File extraction failed. Please check the path is correct"
  }

}
#variables
$path = "C:\Users\Administrator\Desktop\apache_ant_install\dev.properties"
$output = Get-Content $path | ConvertFrom-StringData

$url = $output.url
$destination = $output.destination
$unzip_destination = $output.unzip_destination
$version = $output.version
$servername = $output.servername
$logpath=$output.logpath
Start-Transcript -Path $logpath
$VerbosePreference = "continue"
uninstallAnt "$unzip_destination/$version"

#check server have internet access
if ((Test-Connection -ComputerName $servername -Quiet) -eq "True")
{
  Write-Verbose "Server have Internet access"
  downloadAnt $url $destination $unzip_destination $version
}
else
{
  installAnt $destination $unzip_destination $version
}
#set environment variable
[Environment]::SetEnvironmentVariable("ANT_HOME","$unzip_destination/$version","machine")
[Environment]::SetEnvironmentVariable("Path",$env:Path + ";%ANT_HOME%\bin","Machine")

Stop-Transcript
