$PSScriptRoot

$PCEyeDisplayName = "Tobii Experience Software For Windows (PCEye5)"
$PCEyeLatestVersion = "4.149.0.21578"
$ISeriesDisplayName = "Tobii Experience Software For Windows (I-Series)"
$ISeriesLatestVersion = "4.149.0.21578"

#Pinging ET and checking HW & fw
$fpath = Get-ChildItem -Path $PSScriptRoot -Filter "FWUpgrade32.exe" -Recurse -erroraction SilentlyContinue | Select-Object -expand Fullname | Split-Path
if ($fpath.count -gt 0) {
    Set-Location $fpath
    $Firmware = .\FWUpgrade32.exe --auto --info-only 
    if ($Firmware -match "IS514") {
        $LatestDisplayName = "$PCEyeDisplayName"
        $LatestVersion = "$PCEyeLatestVersion"
        write-host("ET is PCEye5, lastest $LatestDisplayName is $LatestVersion")
    }
    elseif ($Firmware -match "IS502") {
        $LatestDisplayName = "$ISeriesDisplayName"
        $LatestVersion = "$ISeriesLatestVersion"
        Write-Host("ET is I-Series, lastest $LatestDisplayName is $LatestVersion")
    }
    elseif ( $Firmware -match "205 No eye tracker" ) {
        write-host "No tracker connected"
    }
}
else {
    Write-Host " FWUpgrade32.exe is missing" 
}

#Listing Tobii Experience software that installed on this device
$AllListApps = Get-ChildItem -Recurse -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\, HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\, HKLM:\Software\WOW6432Node\Tobii\ | 
Get-ItemProperty | Where-Object { 
    $_.Displayname -like '*Tobii Experience Software*' -or
    $_.Displayname -like '*Tobii Device Drivers*' -or
    $_.Displayname -like '*Tobii Eye Tracking For Windows*'
} 

$AppLists = $AllListApps.DisplayName
if ($AppLists.count -gt 0) {
    Write-Host("Installed ET software on this device are following:")
    $AppLists
}
Write-Host("`r")  

Foreach ($AllListApp in $AllListApps) {
    $DisplayName = $AllListApp.DisplayName
    if ($DisplayName -ne $LatestDisplayName) {
        Write-Host "Deleting $DisplayName.."
        $UninstString = $AllListapp.UninstallString
        $UninstString
        if ($UninstString -match "ProgramData") {
            if (($UninstString -match "4.49.0.4000") -and ($Firmware -match "IS502")) {
                write-host "Run BeforeUninstall.bat script"
                #cmd /c "BeforeUninstall.bat"
            }
            $newUninstString = $AllListapp.UninstallString -replace "msiexec.exe", "" -Replace "/I", "" -Replace "/X", "" -replace "/uninstall", ""
            $uninst3 = $newUninstString.Trim()
            try {
                cmd /c $uninst3 /uninstall /quiet
            }
            catch { 
                Write-Output "it didn't successfully uninstalled $DisplayName"
            }
        }
        else {
            $newUninstString = [regex]::Matches($UninstString, '\{(.*?)\}').Value
            $uninst3 = $newUninstString.Trim()
            Start-process "msiexec.exe" -arg "/X $uninst3 /quiet /norestart" -Wait
        }
    } 
}
Write-Host("`r") 
Foreach ($AllListApp in $AllListApps) {
    $DisplayName = $AllListApp.DisplayName
    if ($DisplayName -eq $LatestDisplayName) {
        Write-Host "Modifying $DisplayName.."
        $ModifyPath = $AllListApp.ModifyPath
        $NewModifyPath = [regex]::Matches($ModifyPath, '\{(.*?)\}').Value
        #Start-process "MsiExec" -arg "/I $NewModifyPath"
    }
}