$PSScriptRoot
$fileversion = "pssleeper"

$fpath = Get-ChildItem -Path $PSScriptRoot -Filter "$fileversion.ps1" -Recurse -erroraction SilentlyContinue | Select-Object -expand Fullname | Split-Path
Set-Location $fpath

Start-Sleep -Seconds 20
$GetProcess = Get-process "*GazeSelection*", "*Tobii*" | Select Processname | Format-table -hidetableheaders | Out-string
$GetServices = Get-Service -Name '*Tobii*' | Select Name, Status | Format-table -hidetableheaders | Out-string
$Firmware = .\fwupgrade.exe --auto --info-only 

if ($GetProcess) {
	Add-content "$fpath\pssleeperoutput.txt" $GetProcess
}
if ($GetServices ) {
	Add-content "$fpath\pssleeperoutput.txt" $GetServices
}



Add-Content "$fpath\pssleeperoutput.txt" $Firmware