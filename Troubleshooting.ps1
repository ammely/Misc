#File version 
$fileversion = "Troubleshooting 0.2"

#Forces powershell to run as an admin
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{ Start-Process powershell.exe "-NoProfile -Windowstyle Hidden -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

#Imports Windowsforms and Drawing from system
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

#Allows the use of wshell for confirmation popups
$wshell = New-Object -ComObject Wscript.Shell
$PSScriptRoot

Function Troubleshoot {
    $outputBox.clear()
 
    $PCEyeDisplayName = "Tobii Experience Software For Windows (PCEye5)"
    $ISeriesDisplayName = "Tobii Experience Software For Windows (I-Series)"
    $ReqServicePCEye5 = "TobiiIS5LARGEPCEYE5"
    $ReqServiceGibbon = "TobiiIS5GIBBONGAZE"
    $PCEyeLatestVersion = "4.149.0.21578"
    $ISeriesLatestVersion = "4.149.0.21578"
    $LatestPDKVersion = "1.36.3.0_59107508"

    #1 Pinging ET and checking HW & fw
    $outputbox.appendtext("===============FIRST===============`r`nPinging ET and checking HW model..`r`n")
    $fpath = Get-ChildItem -Path $PSScriptRoot -Filter "FWUpgrade32.exe" -Recurse -erroraction SilentlyContinue | Select-Object -expand Fullname | Split-Path
    if ($fpath.count -gt 0) {
        Set-Location $fpath
        #Start PDK service
        try {
            #$outputbox.appendtext("Starting PDK..`r`n")
            $getService = Get-Service -Name '*TobiiIS5*'  | start-Service -PassThru -ErrorAction Ignore
        }
        catch {
            $outputbox.appendtext("Error starting PDK. Make sure that ET is connected and there is PDK on this device.`r`n")
        }
        try { 
            $erroractionpreference = "Stop"
            $global:Firmware = .\FWUpgrade32.exe --auto --info-only
            if ($Firmware -match "IS514") {
                $global:LatestDisplayName = "$PCEyeDisplayName"
                $global:LatestVersion = "$PCEyeLatestVersion"
                $outputbox.appendtext("PASS: Connected Eye Tracker is PCEye5`r`n")
            }
            elseif ($Firmware -match "IS502") {
                $global:LatestDisplayName = "$ISeriesDisplayName"
                $global:LatestVersion = "$ISeriesLatestVersion"
                $outputbox.appendtext("PASS: Connected Eye Tracker is I-Series`r`n")
            }
        }
        Catch [System.Management.Automation.RemoteException] {
            write-host("FAIL: No Eye Tracker Connected. Make sure that ET is connected and there is PDK on this device.`r`n")
        }
    }

    #2 Listing Tobii Experience software that installed on this device
    $outputbox.appendtext("`r`n===============Second===============`r`nChecking installed Eye Tracker software..`r`n")
    $AllListApps = Get-ChildItem -Recurse -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\, HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\, HKLM:\Software\WOW6432Node\Tobii\ | 
    Get-ItemProperty | Where-Object { 
        $_.Displayname -like '*Tobii Experience Software*' -or
        $_.Displayname -like '*Tobii Device Drivers*' -or
        $_.Displayname -like '*Tobii Eye Tracking For Windows*' -or
        $_.Displayname -like '*Tobii Eye Tracking*'
    }
    if ($AllListApps) {
        $AppLists = $AllListApps.DisplayName
        if (($AppLists.count -eq 1) -and ($AppLists -eq $LatestDisplayName)) { 
            $DisplayVersion = $AllListApps.displayversion
            if (($DisplayVersion) -and ($DisplayVersion -eq $LatestVersion)) {
				$outputbox.appendtext("PASS: Installed $AppLists is correct, $AppLists $DisplayVersion.`r`n")
            }
            else {
                $outputbox.appendtext("FAIL: $AppLists $DisplayVersion is not the latest. Upgrade the software through Update Notifier.`r`n")
            }
        }
        elseif ($AppLists.count -gt 1) {
            $outputbox.appendtext("FAIL: Installed ET software on this device are following:`r`n")
            foreach ($L in $AppLists) {
                $outputbox.appendtext("$L`r`n")
            }
            $outputbox.appendtext("Uninstall all sw named above and install only $LatestDisplayName.`r`n")
        }
        # Check for Experience app
        $AppPackage = Get-AppxPackage -Name *TobiiAB.TobiiEyeTrackingPortal*
        if ($AppPackage) {
            $outputbox.appendtext("FAIL: $AppPackage Shall be removed.`r`n")
            $regpaths = "HKLM:\SYSTEM\CurrentControlSet\Services\Tobii Interaction Engine",
            "HKLM:\SYSTEM\CurrentControlSet\Services\Tobii Service",
            "HKLM:\SYSTEM\CurrentControlSet\Services\TobiiGeneric",
            "HKLM:\SYSTEM\CurrentControlSet\Services\TobiiIS5LARGEPCEYE5",
            "HKLM:\SYSTEM\CurrentControlSet\Services\TobiiIS5EYETRACKER5"
            if (test-path $regpaths) {
                $outputbox.appendtext("FAIL: Delete $regpaths`r`n") 
            }
        }
    } 
    elseif (!($AllListApps)) {
        $outputbox.appendtext("FAIL: NO Eye Tracker SW installed, install $LatestDisplayName`r`n")
    }

    $AllTDListApps = (Get-ChildItem -Recurse -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\, HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\, HKLM:\Software\WOW6432Node\Tobii\ | 
        Get-ItemProperty | Where-Object { 
        ($_.Displayname -Match "Windows Control") -or
        ($_.Displayname -Match "Tobii Dynavox Gaze Point") -or
        ($_.Displayname -Match "GazeSelection") 
        } | Select-Object Displayname, UninstallString).DisplayName
    if ($AllTDListApps -gt 0) {
        $outputbox.appendtext("FAIL: $AllTDListApps shall be removed. Uninstall also Tobii Dynavox Eye Tracking and re-install it again.`r`n")
    } 

    #3 Getting Services that installed on this device
    $outputbox.appendtext("`r`n===============THIRD===============`r`nChecking services..`r`n")
    $GetService = Get-Service -Name '*Tobii*'
    #Listing all installed Services
    if ($GetService.count -ne 0) {
        $EyeXPath = "C:\Program Files\Tobii\Tobii EyeX"
        if (Test-Path $EyeXPath) {
            if ($global:Firmware -match "IS502") {
                $global:ReqService = $ReqServiceGibbon
                $PDKversions = Get-ChildItem -Path $EyeXPath -Recurse -file -include "platform_runtime_IS5GIBBONGAZE_service.exe" | foreach-object { "{0}`t{1}" -f $_.Name, [System.Diagnostics.FileVersionInfo]::GetVersionInfo($_).FileVersion }
            }
            elseif ($global:Firmware -match "IS514") {
                $global:ReqService = $ReqServicePCEye5
                $PDKversions = Get-ChildItem -Path $EyeXPath -Recurse -file -include "platform_runtime_IS5LARGEPCEYE5_service.exe" | foreach-object { "{0}`t{1}" -f $_.Name, [System.Diagnostics.FileVersionInfo]::GetVersionInfo($_).FileVersion }
            } 
        } 
        if ($ReqService) {
            $Compares = (Compare-Object -DifferenceObject $GetService -ReferenceObject $ReqService -CaseSensitive -ExcludeDifferent -IncludeEqual | Select-Object InputObject).InputObject
            if ($Compares -eq $ReqService ) {
                if ($PDKversions -match $LatestPDKVersion) {
					$outputbox.appendtext("PASS: Latest PDK ($ReqService) $PDKversions is installed`r`n")
                }
                else {
                    $outputbox.appendtext("FAIL: PDK ($ReqService $PDKversions) is not the latest, make sure that $LatestDisplayName is installed.`r`n")
                }
                $TobiiService = $GetService | Where-Object { $_.Name -eq "Tobii Service" }
                if ( $TobiiService) {
                    $outputbox.appendtext("PASS: Tobii Service is installed`r`n")
                }
                elseif (!($TobiiService)) {
                    $outputbox.appendtext("FAIL: Tobii Service is not intsalled. Uninstall Tobii Experince Software and re-install it again.`r`n")
                }
                $ServiceStatus = ($GetService | Where-Object { $_.Status -ne "Running" }).name
                If ($ServiceStatus) {
                    foreach ($ServiceStatuss in $ServiceStatus) {
                        $outputbox.appendtext("FAIL: $ServiceStatuss is not running. Open Task Manager and run the service.`r`n")
                    }
                }
				$AvaliablePDK = (Get-Service -DisplayName "*Tobii Runtime Service*").name
                $ComparesPDK = (Compare-Object -DifferenceObject $AvaliablePDK -ReferenceObject $Compares -CaseSensitive  | Select-Object InputObject).InputObject
                if (($ComparesPDK)) {
                    $outputbox.appendtext("FAIL: $ComparesPDK should not be installed. Please remove it!`r`n")
                }
            } 
            elseif (!($Compares) ) { 
                $outputbox.appendtext("FAIL: NO PDK INSTALLED. Make sure $LatestDisplayName is installed.`r`n")
            }
        } 
    } 
    else {
        $outputbox.appendtext("FAIL: No ET Service found. Make sure $LatestDisplayName is installed.`r`n")
    }

    #4 Getting Processes that running on this device
    $outputbox.appendtext("`r`n===============FOURTH===============`r`nChecking processes..`r`n")
    $TobiiProcesses = "Tobii.EyeX.Engine", "Tobii.EyeX.Interaction", "Tobii.Service", "TobiiDynavox.EyeAssist.Engine", "TobiiDynavox.EyeAssist.RegionInteraction.Startup", "TobiiDynavox.EyeAssist.Smorgasbord", "TobiiDynavox.EyeAssist.TrayIcon", "TobiiDynavox.EyeTrackingSettings"
    foreach ($TobiiProcess in $TobiiProcesses) {
        Try {
            $erroractionpreference = "Stop"
            $GetTobiiProcess = Get-Process $TobiiProcess | Select-Object ProcessName
        }
        catch {
            $outputbox.appendtext("FAIL: $TobiiProcess is not running. Open Task Manager and run the process.`r`n")
        }
    }

    #5 Getting drivers that installed on this device
    $outputbox.appendtext("`r`n===============FIFTH===============`r`nChecking drivers`r`n")
    $TobiiDrivers = Get-WindowsDriver -Online | Where-Object { $_.OriginalFileName -match "Tobii" } | Sort-object OriginalFileName -desc | select OriginalFileName, Driver
    if ($TobiiDrivers.count -ne 0) {
        $NewTobiiDrivers = $TobiiDrivers.originalfilename -replace "C:", "" -replace "(?<=\\).+?(?=\\)", "" -replace "\\\\\\", "" 
        $outputbox.appendtext("Listing all available drivers..`r`n")
        foreach ($TD in $NewTobiiDrivers) {
            $outputbox.appendtext("$TD`r`n")
        }
        $b = $NewTobiiDrivers | select -Unique
        $CompareDrivers = (Compare-Object -ReferenceObject $b -DifferenceObject $NewTobiiDrivers | Select-Object InputObject).InputObject
        if ($CompareDrivers.count -gt 0) {
            $outputbox.appendtext("FAIL: There are two drivers of $CompareDrivers. Uninstall Tobii Experience Software and re-install it again.`r`n")
        } 
        foreach ($NewTobiiDriver in $NewTobiiDrivers) {
            if (($NewTobiiDriver -match "is") -or ($NewTobiiDriver -match "dmft")) {
                $outputbox.appendtext("FAIL: $NewTobiiDriver is not belong to this HW! Remove all sw in second step and install only Tobii Experience Software and Tobii Dynavox Eye Tracking.`r`n")
            }
        }
        $outputbox.appendtext("`r`nVerify correct Hello Driver with HW..`r`n")
        foreach ($NewTobiiDriver in $NewTobiiDrivers) {
            if ($NewTobiiDriver -match "318") {
                $outputbox.appendtext("$NewTobiiDriver belong to PCEye5`r`n")
            }
            elseif ($NewTobiiDriver -match "304") {
                $outputbox.appendtext("$NewTobiiDriver belong to I-Series`r`n")
            }
        }
    }
    $SignedDrivers = (Get-WmiObject Win32_PnPSignedDriver | Where-Object { $_.Manufacturer -match "Tobii" } | select DeviceName).DeviceName
    $d = "Tobii Hello Sensor", "Tobii Eye Tracker HID", "Tobii Device"
    $CompareSignedDrivers = (Compare-Object -ReferenceObject $d -DifferenceObject $SignedDrivers | Where-Object { $_.SideIndicator -eq "<=" }).InputObject
    if ($CompareSignedDrivers.count -gt 0) {
        $outputbox.appendtext("FAIL: $CompareSignedDrivers are missing. Uninstall Tobii Experience Software and re-install it again.`r`n" )
    }
    #List from Device Manager
    $GetDriverStatus = (Get-PnpDevice -FriendlyName '*Tobii*' | Sort-object FriendlyName -desc | Where-Object { $_.Status -ne "OK" } | Select-Object FriendlyName, InstanceId).FriendlyName
    if ($GetDriverStatus.count -gt 0) {
        $outputbox.appendtext("FAIL: $GetDriverStatus is not properly running..Uninstall Tobii Experience Software and re-install it again.`r`n")
    }

    #6 Check if there are valid calibration profiles
    $outputbox.appendtext("`r`n===============SIXTH===============`r`nChecking calibration profiles and display setup`r`n")
    $EyeXConfig = "HKLM:\SOFTWARE\WOW6432Node\Tobii\EyeXConfig"
    if (Test-path $EyeXConfig) {
        $CurrentProfile = (Get-itemproperty -Path $EyeXConfig).currentuserprofile
        if ($CurrentProfile.count -gt 0) {
            $outputbox.appendtext("PASS: Active profile is $currentprofile`r`n")
        }
        else {
            $outputbox.appendtext("FAIL: No active profile. Open Tobii Dynavox Eye Tracking and create a new calibration profile.`r`n")
        }
    }

    $UserProfile = "HKLM:\SOFTWARE\WOW6432Node\Tobii\EyeXConfig\UserProfiles"
    if (Test-Path $UserProfile) {
        $getCalbfolders = (Get-ChildItem -Path $UserProfile).name | Split-Path -Leaf
        if ($getCalbfolders.count -gt 0) {
            $outputbox.appendtext("Following Calibration profiles are created in this device:`r`n")
            foreach ($getCalbfolder in $getCalbfolders) {
                $f = (Get-ChildItem -Path "$UserProfile\$getCalbfolder" -Recurse).property
                if ($f.contains('Data')) {
                    $outputbox.appendtext("PASS: $getCalbfolder is created, Data file is exist`r`n")
                }
                else { 
                    $outputbox.appendtext("FAIL: $getCalbfolder is created, but Data file is not exist. Open Tobii Dynavox Eye Tracking and re-calibrate $getCalbfolder.`r`n")
                }
            }
        } 
        elseif ($getCalbfolders.count -eq 0) {
            $outputbox.appendtext("FAIL: No Calibration Profile stored in this device. Open Tobii Dynavox Eye Tracking and create a new calibration profile.`r`n")
        }   
    }

    #Check for valid display-setup
    $regEntryPath = 'HKLM:\SOFTWARE\WOW6432Node\Tobii\EyeXConfig\MonitorMappings'
    $referenceValues = "ActiveDisplayArea", "AspectRatioHeight", "AspectRatioWidth"
    try {
        $erroractionpreference = "Stop"
        $keyValue = (Get-ChildItem -Path $regEntryPath).property 
        $comparekeys = (Compare-Object -DifferenceObject $keyValue -ReferenceObject $referenceValues -CaseSensitive).inputobject
        if ($comparekeys.count -gt 0) {
            $outputbox.appendtext("FAIL: No display values has been found! Open Tobii Dynavox Eye Tracking and perform display setup if possible.`r`n")
        }
        elseif ($comparekeys.count -eq 0) { 
            $outputbox.appendtext("PASS: Display setup has been performed!`r`n")
        }
    } 
    catch {
        $outputbox.appendtext("FAIL: No display setup has been found! Open Tobii Dynavox Eye Tracking and perform display setup if possible.`r`n")
    }
    #pause
    $outputbox.appendtext("Done!`r`n")
}



#Windows forms
#$Optionlist = @("Remove Progressive Sweet", "Remove PCEye5 Bundle", "Remove all ET SW", "Remove WC&GP Bundle", "Remove VC++", "Remove PCEye Package", "Remove Communicator", "Remove Compass", "Remove TGIS only", "Remove TGIS profile calibrations", "Remove all users C5", "Backup Gaze Interaction", "Copy License")
$Form = New-Object System.Windows.Forms.Form
$Form.Size = New-Object System.Drawing.Size(600, 590)
$Form.FormBorderStyle = 'Fixed3D'
$Form.MaximizeBox = $False


#Outputbox
$outputBox = New-Object System.Windows.Forms.TextBox
$outputBox.Location = New-Object System.Drawing.Size(10, 100)
$outputBox.Size = New-Object System.Drawing.Size(560, 400)
$outputBox.MultiLine = $True
$outputBox.ScrollBars = "Vertical"
$Form.Controls.Add($outputBox)
$outputBox.font = New-Object System.Drawing.Font ("Consolas" , 8, [System.Drawing.FontStyle]::Regular)

#B1 Button1 "List Tobii Software"
$Button1 = New-Object System.Windows.Forms.Button
$Button1.Location = New-Object System.Drawing.Size(30, 30)
$Button1.Size = New-Object System.Drawing.Size(150, 70)
$Button1.Text = "Troubleshoot"
$Button1.Font = New-Object System.Drawing.Font ("" , 8, [System.Drawing.FontStyle]::Regular)
$form.Controls.add($Button1)
$Button1.Add_Click{ Troubleshoot }

#Form name + activate form.
$Form.Text = $fileversion
$Form.Add_Shown( { $Form.Activate() })
$Form.ShowDialog()