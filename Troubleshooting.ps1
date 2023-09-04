#Author AMMAR ELYAS - TobiiDynavox

#File version 
$fileversion = "Troubleshooting 0.4.ps1"
$PCEyeLatestVersion = "4.149.0.21578"
$ISeriesLatestVersion = "4.149.0.21578"
$LatestPDKVersion = "1.36.3.0_59107508"

#Forces powershell to run as an admin
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{ Start-Process powershell.exe "-NoProfile -Windowstyle Hidden -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

#Imports Windowsforms and Drawing from system
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

#Allows the use of wshell for confirmation popups
$wshell = New-Object -ComObject Wscript.Shell
$PSScriptRoot


Function Write-Log {
    Param ($Message)
    $fpath = Get-ChildItem -Path $PSScriptRoot -Filter "$fileversion" -Recurse -erroraction SilentlyContinue | Select-Object -expand Fullname | Split-Path
    Set-Location $fpath
    "$(get-date -format "yyyy-MM-dd HH:mm:ss"): $($Message)" | out-file "$fpath\TroubleshootingLog.txt" -Append
    $OutputBox.AppendText("$Message" + "`r`n" )
}
Function Troubleshoot {
    $outputBox.clear()
 
    $PCEyeDisplayName = "Tobii Experience Software For Windows (PCEye5)"
    $ISeriesDisplayName = "Tobii Experience Software For Windows (I-Series)"
    $ReqServicePCEye5 = "TobiiIS5LARGEPCEYE5"
    $ReqServiceGibbon = "TobiiIS5GIBBONGAZE"

    #1 Pinging ET and checking HW & fw
    Write-Log -Message "===============FIRST===============`r`nPinging ET and checking HW model.."
    $fpath = Get-ChildItem -Path $PSScriptRoot -Filter "Tdx.EyeTrackerInfo.exe" -Recurse -erroraction SilentlyContinue | Select-Object -expand Fullname | Split-Path
    if ($fpath.count -gt 0) {
        Set-Location $fpath
        #Start PDK service
        try {
            $getService = Get-Service -Name '*TobiiIS5*'  | start-Service -PassThru -ErrorAction Ignore
        }
        catch {
            Write-Log -Message "Error starting PDK. Make sure that ET is connected and (TobiiIS5XXXX) available in Task Manager-Services."
        }
        try { 
            $erroractionpreference = "Stop"
            $global:serialnumber = .\Tdx.EyeTrackerInfo.exe --serialnumber
            if ($serialnumber -match "IS514") {
                $global:LatestDisplayName = "$PCEyeDisplayName"
                $global:LatestVersion = "$PCEyeLatestVersion"
                Write-Log -Message "PASS: Connected Eye Tracker is PCEye5 with S/N $serialnumber"
            }
            elseif ($serialnumber -match "IS502") {
                $global:LatestDisplayName = "$ISeriesDisplayName"
                $global:LatestVersion = "$ISeriesLatestVersion"
                Write-Log -Message "PASS: Connected Eye Tracker is I-Series with S/N $serialnumber"
            }
        }
        Catch [System.Management.Automation.RemoteException] {
            Write-Log -Message "FAIL: No Eye Tracker Connected. Make sure that ET is connected and there is PDK on this device."
        }
    }

    #2 Listing Tobii Experience software that installed on this device
    Write-Log -Message "===============SECOND===============`r`nChecking installed Eye Tracker software.."
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
                Write-Log -Message "PASS: Installed $AppLists is correct, $AppLists $DisplayVersion."
            }
            else {
                Write-Log -Message "FAIL: $AppLists $DisplayVersion is not the latest. Upgrade the software through Update Notifier."
            }
        }
        elseif ($AppLists.count -gt 1) {
            Write-Log -Message "FAIL: Installed ET software on this device are following:"
            foreach ($L in $AppLists) {
                Write-Log -Message "$L`r`n"
            }
            Write-Log -Message "Uninstall all sw named above and install only $LatestDisplayName $LatestVersion."
        }
        # Check for Experience app
        $AppPackage = Get-AppxPackage -Name *TobiiAB.TobiiEyeTrackingPortal*
        if ($AppPackage) {
            Write-Log -Message "FAIL: $AppPackage Shall be removed."
            $regpaths = "HKLM:\SYSTEM\CurrentControlSet\Services\Tobii Interaction Engine",
            "HKLM:\SYSTEM\CurrentControlSet\Services\Tobii Service",
            "HKLM:\SYSTEM\CurrentControlSet\Services\TobiiGeneric",
            "HKLM:\SYSTEM\CurrentControlSet\Services\TobiiIS5LARGEPCEYE5",
            "HKLM:\SYSTEM\CurrentControlSet\Services\TobiiIS5EYETRACKER5"
            if (test-path $regpaths) {
                Write-Log -Message "FAIL: Delete $regpaths"
            }
        }
    } 
    elseif (!($AllListApps)) {
        Write-Log -Message "FAIL: NO Eye Tracker SW installed, install $LatestDisplayName $LatestVersion."
    }

    $AllTDListApps = (Get-ChildItem -Recurse -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\, HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\, HKLM:\Software\WOW6432Node\Tobii\ | 
        Get-ItemProperty | Where-Object { 
        ($_.Displayname -Match "Windows Control") -or
        ($_.Displayname -Match "Tobii Dynavox Gaze Point") -or
        ($_.Displayname -Match "GazeSelection") 
        } | Select-Object Displayname, UninstallString).DisplayName
    if ($AllTDListApps -gt 0) {
        Write-Log -Message "FAIL: $AllTDListApps shall be removed. Uninstall also Tobii Dynavox Eye Tracking and re-install it again."
    }

    #3 Getting installed Services that installed on this device
    Write-Log -Message "===============THIRD===============`r`nChecking services.."
    $GetService = Get-Service -Name '*Tobii*'
    #Listing all installed Services
    if ($GetService.count -ne 0) {
        $EyeXPath = "C:\Program Files\Tobii\Tobii EyeX"
        if (Test-Path $EyeXPath) {
            if ($global:serialnumber -match "IS502") {
                $global:ReqService = $ReqServiceGibbon
                $PDKversions = Get-ChildItem -Path $EyeXPath -Recurse -file -include "platform_runtime_IS5GIBBONGAZE_service.exe" | foreach-object { "{0}`t{1}" -f $_.Name, [System.Diagnostics.FileVersionInfo]::GetVersionInfo($_).FileVersion }
            }
            elseif ($global:serialnumber -match "IS514") {
                $global:ReqService = $ReqServicePCEye5
                $PDKversions = Get-ChildItem -Path $EyeXPath -Recurse -file -include "platform_runtime_IS5LARGEPCEYE5_service.exe" | foreach-object { "{0}`t{1}" -f $_.Name, [System.Diagnostics.FileVersionInfo]::GetVersionInfo($_).FileVersion }
            } 
        } 
        if ($ReqService) {
            $Compares = (Compare-Object -DifferenceObject $GetService -ReferenceObject $ReqService -CaseSensitive -ExcludeDifferent -IncludeEqual | Select-Object InputObject).InputObject
            if ($Compares -eq $ReqService ) {
                if ($PDKversions -match $LatestPDKVersion) {
                    Write-Log -Message "PASS: Latest PDK ($ReqService) $PDKversions is installed."
                }
                else {
                    Write-Log -Message "FAIL: PDK ($ReqService $PDKversions) is not the latest, make sure that $LatestDisplayName $LatestVersion is installed."
                }
                $TobiiService = $GetService | Where-Object { $_.Name -eq "Tobii Service" }
                if ( $TobiiService) {
                    Write-Log -Message "PASS: Tobii Service is installed."
                }
                elseif (!($TobiiService)) {
                    Write-Log -Message "FAIL: Tobii Service is not intsalled. Uninstall Tobii Experince Software and re-install it again."
                }
                $ServiceStatus = ($GetService | Where-Object { $_.Status -ne "Running" }).name
                If ($ServiceStatus) {
                    foreach ($ServiceStatuss in $ServiceStatus) {
                        Write-Log -Message "FAIL: $ServiceStatuss is not running. Open Task Manager and run the service."
                    }
                }
                $AvaliablePDK = (Get-Service -DisplayName "*Tobii Runtime Service*").name
                $ComparesPDK = (Compare-Object -DifferenceObject $AvaliablePDK -ReferenceObject $Compares -CaseSensitive  | Select-Object InputObject).InputObject
                if (($ComparesPDK)) {
                    Write-Log -Message "FAIL: $ComparesPDK should not be installed. Please remove it!"
                }
            } 
            elseif (!($Compares) ) { 
                Write-Log -Message "FAIL: NO PDK INSTALLED. Make sure $LatestDisplayName is installed."
            }
        } 
    } 
    else {
        Write-Log -Message "FAIL: No ET Service found. Make sure $LatestDisplayName is installed."
    }

    #4 Getting Processes that running on this device
    Write-Log -Message "===============FOURTH===============`r`nChecking processes.."
    $TobiiProcesses = "Tobii.EyeX.Engine", "Tobii.EyeX.Interaction", "Tobii.Service", "TobiiDynavox.EyeAssist.Engine", "TobiiDynavox.EyeAssist.RegionInteraction.Startup", "TobiiDynavox.EyeAssist.Smorgasbord", "TobiiDynavox.EyeAssist.TrayIcon", "TobiiDynavox.EyeTrackingSettings"
    foreach ($TobiiProcess in $TobiiProcesses) {
        Try {
            $erroractionpreference = "Stop"
            $GetTobiiProcess = Get-Process $TobiiProcess | Select-Object ProcessName
        }
        catch {
            Write-Log -Message "FAIL: $TobiiProcess is not running. Open Task Manager and run the process."
        }
    }

    #5 Getting drivers that installed on this device
    Write-Log -Message "===============FIFTH===============`r`nChecking drivers.."
    $TobiiWindowsDrivers = Get-WindowsDriver -Online | Where-Object { $_.OriginalFileName -match "Tobii" } | Sort-object OriginalFileName -desc | Select-Object OriginalFileName, Driver
    if ($TobiiWindowsDrivers.count -ne 0) {
        $NewTobiiDrivers = $TobiiWindowsDrivers.originalfilename -replace "C:", "" -replace "(?<=\\).+?(?=\\)", "" -replace "\\\\\\", "" 

        $b = $NewTobiiDrivers | Select-Object -Unique
        $CompareDrivers = (Compare-Object -ReferenceObject $b -DifferenceObject $NewTobiiDrivers | Select-Object InputObject).InputObject
        if ($CompareDrivers.count -gt 0) {
            Write-Log -Message "FAIL: There are two drivers of $CompareDrivers. Uninstall Tobii Experience Software and re-install it again."
        }
         
        foreach ($NewTobiiDriver in $NewTobiiDrivers) {
            if (($NewTobiiDriver -match "is") -or ($NewTobiiDriver -match "dmft")) {
                Write-Log -Message "FAIL: $NewTobiiDriver is not belong to this HW! Remove all sw in second step and install only Tobii Experience Software and Tobii Dynavox Eye Tracking."
            }
            
            if (($NewTobiiDriver -match "318") -and ($global:serialnumber -match "IS502")) {
                Write-Log -Message "FAIL: $NewTobiiDriver belong to PCEye5."
            }
            elseif (($NewTobiiDriver -match "304") -and ($global:serialnumber -match "IS514")) {
                Write-Log -Message "FAIL: $NewTobiiDriver belong to I-Series."
            }
        }
    }

    $SignedDrivers = (Get-WmiObject Win32_PnPSignedDriver | Where-Object { $_.Manufacturer -match "Tobii" } | Select-Object DeviceName).DeviceName
    $d = "Tobii Hello Sensor", "Tobii Eye Tracker HID", "Tobii Device"
    $CompareSignedDrivers = (Compare-Object -ReferenceObject $d -DifferenceObject $SignedDrivers | Where-Object { $_.SideIndicator -eq "<=" }).InputObject
    if ($CompareSignedDrivers.count -gt 0) {
        Write-Log -Message "FAIL: $CompareSignedDrivers is missing. Uninstall Tobii Experience Software and re-install it again." 
    }

    #List from Device Manager
    #$GetDriverStatus = (Get-PnpDevice -FriendlyName '*Tobii*' | Where-Object { $_.Status -ne "OK" } | Select-Object FriendlyName, InstanceId).FriendlyName
    $GetPnpDrivers = Get-PnpDevice -FriendlyName '*Tobii*' | Select-Object Status, Class, FriendlyName, InstanceId
    $ReferencePnpDrivers = "Tobii Device", "Tobii Hello Sensor", "Tobii Eye Tracker HID"

    foreach ($GetPnpDriver in $GetPnpDrivers ) {
        if ($GetPnpDriver.Status -ne "OK") {
            $getPnpDriverName = $GetPnpDriver.FriendlyName
            $getPnpDriverStatus = $GetPnpDriver.status
            Write-Log -Message "FAIL: $getPnpDriverName Status is $getPnpDriverStatus..Make sure that all services are running or uninstall Tobii Experience Software and re-install it again."
            #write-host $GetPnpDriver.FriendlyName "Status is" $GetPnpDriver.status
        }
    }
    $ComparePnpDrivers = (Compare-Object -ReferenceObject $ReferencePnpDrivers -DifferenceObject $GetPnpDrivers.FriendlyName | Where-Object { $_.SideIndicator -eq "<=" }).InputObject
    if ($ComparePnpDrivers -gt 0) {
        foreach ($ComparePnpDriver in  $ComparePnpDrivers) {
            Write-Log -Message "FAIL: $ComparePnpDriver is missing, Uninstall Tobii Experience Software and re-install it again."
        }
    }
        






    #6 Check if there are valid calibration profiles
    Write-Log -Message "===============SIXTH===============`r`nChecking calibration profiles and display setup.."
    $EyeXConfig = "HKLM:\SOFTWARE\WOW6432Node\Tobii\EyeXConfig"
    if (Test-path $EyeXConfig) {
        $CurrentProfile = (Get-itemproperty -Path $EyeXConfig).currentuserprofile
        if ($CurrentProfile.count -gt 0) {
            Write-Log -Message "PASS: Active profile is $currentprofile."
        }
        else {
            Write-Log -Message "FAIL: No active profile. Open Tobii Dynavox Eye Tracking and create a new calibration profile."
        }
    }

    $UserProfile = "HKLM:\SOFTWARE\WOW6432Node\Tobii\EyeXConfig\UserProfiles"
    if (Test-Path $UserProfile) {
        $getCalbfolders = (Get-ChildItem -Path $UserProfile).name | Split-Path -Leaf
        if ($getCalbfolders.count -gt 0) {
            Write-Log -Message "Following Calibration profiles are created in this device:"
            foreach ($getCalbfolder in $getCalbfolders) {
                $f = (Get-ChildItem -Path "$UserProfile\$getCalbfolder" -Recurse).property
                if ($f.contains('Data')) {
                    Write-Log -Message "PASS: $getCalbfolder is created, Data file is exist."
                }
                else { 
                    Write-Log -Message "FAIL: $getCalbfolder is created, but Data file is not exist. Open Tobii Dynavox Eye Tracking and re-calibrate $getCalbfolder."
                }
            }
        } 
        elseif ($getCalbfolders.count -eq 0) {
            Write-Log -Message "FAIL: No Calibration Profile stored in this device. Open Tobii Dynavox Eye Tracking and create a new calibration profile."
        }   
    }    

    #display-setup
    $regEntryPath = 'HKLM:\SOFTWARE\WOW6432Node\Tobii\EyeXConfig\MonitorMappings'
    $referenceValues = "ActiveDisplayArea", "AspectRatioHeight", "AspectRatioWidth"
    try {
        $erroractionpreference = "Stop"
        $keyValue = (Get-ChildItem -Path $regEntryPath).property 
        $comparekeys = (Compare-Object -DifferenceObject $keyValue -ReferenceObject $referenceValues -CaseSensitive).inputobject
        if ($comparekeys.count -gt 0) {
            Write-Log -Message "FAIL: No display values has been found! Open Tobii Dynavox Eye Tracking and perform display setup if possible."
        }
        elseif ($comparekeys.count -eq 0) { 
            Write-Log -Message "PASS: Display setup has been performed!"
        }
    } 
    catch {
        Write-Log -Message "FAIL: No display setup has been found! Open Tobii Dynavox Eye Tracking and perform display setup if possible."
    }
    #pause
    Write-Log -Message "Done!"
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