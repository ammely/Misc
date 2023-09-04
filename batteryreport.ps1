$PSScriptRoot
$key = 'HKLM:\SOFTWARE\WOW6432Node\Tobii Dynavox\Device'
$fpath = Get-ChildItem -Path $PSScriptRoot -Filter "batteryreport.ps1" -Recurse -erroraction SilentlyContinue | Select-Object -expand Fullname | Split-Path
Set-Location $fpath

if (Test-Path $key) {
    $SerialNumber = (Get-ItemProperty -Path $key)."Serial Number" 
    Add-Content -path "DeviceInfo.txt" -Value "Device's Serial Number is $SerialNumber"
    Write-host "Device Serial Number is $SerialNumber"
    
    $OEMImage = (Get-ItemProperty -Path $key)."OEM Image" 
    Add-Content -path "DeviceInfo.txt" -Value "Device's OEM Image is $OEMImage"
    Write-host "Device OEM Image is $OEMImage"

    $ProductKey = (Get-ItemProperty -Path $key)."Product Key"
    Add-Content -path "DeviceInfo.txt" -Value "Device's Product Key is $ProductKey"
    Write-host "Device Product Key is $ProductKey"
} else {
    $SerialNumber = (Get-CimInstance -ClassName Win32_bios).SerialNumber
    $Model = (Get-CimInstance -ClassName Win32_ComputerSystem).Model
    Add-Content -path "DeviceInfo.txt" -Value "This device is not TD device"
    Add-Content -path "DeviceInfo.txt" -Value "Device's Serial Number is $SerialNumber"
    Add-Content -path "DeviceInfo.txt" -Value "Device's Model is $Model"
}

if ($SerialNumber -match "TD110-") {
    write-host "Battery report is not support on this device, runt I-110MLK.bat to get the report."
} else {
    powercfg /batteryreport /output "$SerialNumber-battery-report.html"
}

$DesignedCapacity = (Get-WmiObject -Class BatteryStaticData -Namespace ROOT\WMI).DesignedCapacity/1000
Add-Content -path "DeviceInfo.txt" -Value "Battery Designed Capacity is $DesignedCapacity mWh"
write-host "Design Capacity is $DesignedCapacity mWh"

$FullChargedCapacity = (Get-WmiObject -Class BatteryFullChargedCapacity -Namespace ROOT\WMI).FullChargedCapacity/1000
Add-Content -path "DeviceInfo.txt" -Value "Battery Full Charged Capacity is $FullChargedCapacity mWh"
write-host "Full Charge Capacity is $FullChargedCapacity mWh"

#$BatteryHealth = ($FullChargedCapacity/$DesignedCapacity)
$BatteryHealth = [Math]::Round($FullChargedCapacity/$DesignedCapacity*100)
Add-Content -path "DeviceInfo.txt" -Value "Battery Health is $BatteryHealth %`r`n"
write-host "Battery Health is $BatteryHealth %"

Read-Host -Prompt "Press Enter to exit"