Start-sleep -s 1

$getinfo = cmd /c "C:/Program Files (x86)/Tobii/Service/FWUpgrade32.exe" --auto --info-only | out-string
$time = Get-Date -UFormat %H:%M:%S
<# Add-content Q:\output.txt $time,$getinfo #>
Add-content D:\Scripts\output.txt $time,$getinfo