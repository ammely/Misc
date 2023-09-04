#_V0.7
#Forces powershell to run as an admin
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{ Start-Process powershell.exe "-NoProfile -Windowstyle Hidden -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }


Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Error logs collector v.0.7'
$form.Size = New-Object System.Drawing.Size(420, 320)
$form.StartPosition = 'CenterScreen'

$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = New-Object System.Drawing.Point(135, 250)
$okButton.Size = New-Object System.Drawing.Size(75, 25)
$okButton.Text = 'OK'
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $okButton
$form.Controls.Add($okButton)

$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Location = New-Object System.Drawing.Point(210, 250)
$cancelButton.Size = New-Object System.Drawing.Size(75, 25)
$cancelButton.Text = 'Cancel'
$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $cancelButton
$form.Controls.Add($cancelButton)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10, 10)
$label.Size = New-Object System.Drawing.Size(110, 20)
$label.Text = "Log folder located in:"
$form.Controls.Add($label)

$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Location = New-Object System.Drawing.Point(120, 10)
$textBox.Size = New-Object System.Drawing.Size(240, 20)
$form.Controls.Add($textBox)

$label2 = New-Object System.Windows.Forms.Label
$label2.Location = New-Object System.Drawing.Point(10, 30)
$label2.Size = New-Object System.Drawing.Size(400, 30)
$label2.Text = "ex. C:\Users\TobiiDynavox_SysInfo_xxxx `nResults will be saved in ErrorLogs at the same path as given above."
$form.Controls.Add($label2)

$label3 = New-Object System.Windows.Forms.Label
$label3.Location = New-Object System.Drawing.Point(10, 60)
$label3.Size = New-Object System.Drawing.Size(400, 80)
$label3.Text = "A. Which error logs are you looking for(choose only a number): `n1 Latest logs `n2 Eye Assist logs `n3 Driver software logs `n4 Driver installer logs `n5 Any other file or folder in the path"
$form.Controls.Add($label3)

$textBox2 = New-Object System.Windows.Forms.TextBox
$textBox2.Location = New-Object System.Drawing.Point(10, 140)
$textBox2.Size = New-Object System.Drawing.Size(100, 20)
$form.Controls.Add($textBox2)

$label4 = New-Object System.Windows.Forms.Label
$label4.Location = New-Object System.Drawing.Point(10, 160)
$label4.Size = New-Object System.Drawing.Size(400, 20)
$label4.Text = "B. Timestamp logs, format should be as: 2021-01-01 12:30"
$form.Controls.Add($label4)

$textBox3 = New-Object System.Windows.Forms.TextBox
$textBox3.Location = New-Object System.Drawing.Point(10, 180)
$textBox3.Size = New-Object System.Drawing.Size(100, 20)
$form.Controls.Add($textBox3)

$label5 = New-Object System.Windows.Forms.Label
$label5.Location = New-Object System.Drawing.Point(10, 200)
$label5.Size = New-Object System.Drawing.Size(400, 20)
$label5.Text = "C. Logs between two timestamps:"
$form.Controls.Add($label5)

$textBox4 = New-Object System.Windows.Forms.TextBox
$textBox4.Location = New-Object System.Drawing.Point(10, 220)
$textBox4.Size = New-Object System.Drawing.Size(100, 20)
$form.Controls.Add($textBox4)

$textBox5 = New-Object System.Windows.Forms.TextBox
$textBox5.Location = New-Object System.Drawing.Point(180, 220)
$textBox5.Size = New-Object System.Drawing.Size(100, 20)
$form.Controls.Add($textBox5)

$form.Topmost = $true

$form.Add_Shown( { $textBox.Select() })
$result = $form.ShowDialog()
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force

if ($x -and $x2 -and $x3) {
    Clear-Variable x3
    Clear-Variable x2
    Clear-Variable x
}

Function GetETLatestErrorLogs {
    $LogPath = $x
    $files = (    
        "$LogPath\COMPUTER_CONTROL_APPDATA_LOGS\ComputerControl.log",
        "$LogPath\COMPUTER_CONTROL_PROGRAMDATA_LOGS\ComputerControl.Updater.log",
        "$LogPath\TOBII_DYNAVOX_APPDATA\EYEASSIST\LOGS\EyeAssistEngine.log",
        "$LogPath\TOBII_DYNAVOX_APPDATA\EYEASSIST\LOGS\EyeTrackingSettings.log",
        "$LogPath\TOBII_DYNAVOX_APPDATA\EYEASSIST\LOGS\RegionInteraction.log",
        "$LogPath\TOBII_LOCALAPPDATA\Tobii%20Interaction\InteractionLog.txt",
        "$LogPath\TOBII_LOCALAPPDATA\Tobii%20Interaction\ServerLog.txt",
        "$LogPath\TOBII_PROGRAMDATA\Tobii%20Interaction\ServiceLog.txt",
        "$LogPath\TOBII_PROGRAMDATA\Tobii%20Platform%20Runtime\IS5GIBBONGAZE\pr_log0.txt",
        "$LogPath\Logs\Computer Control\AppData\Logs\ComputerControl.log",
        "$LogPath\Logs\Computer Control\ProgramData\Logs\ComputerControl.Updater.log",
        "$LogPath\Logs\Eye Assist\Logs\EyeAssistEngine.log",
        "$LogPath\Logs\Eye Assist\Logs\EyeTrackingSettings.log",
        "$LogPath\Logs\Eye Assist\Logs\RegionInteraction.log",
        "$LogPath\Logs\Tobii Interaction\LocalAppData\InteractionLog.txt",
        "$LogPath\Logs\Tobii Interaction\LocalAppData\ServerLog.txt",
        "$LogPath\Logs\Tobii Interaction\ProgramData\ServiceLog.txt",
        "$LogPath\Logs\Tobii Platform Runtime\IS5GIBBONGAZE\pr_log0.txt"
    )

    #Creating folder   
    $ErrorPath = "$LogPath\ErrorLogs"
    if (!(Test-Path "$ErrorPath")) {
        Write-Host "Creating ErrorLogs folder.."
        New-Item -Path "$ErrorPath" -ItemType Directory  
    }
    #Creating files
    if (!(Test-Path "$ErrorPath\LatestErrors.txt")) {
        New-Item -Path $ErrorPath -Name "LatestErrors.txt" -ItemType "file"
        Write-Host "creating file"
    }
    else {
        Clear-Content -Path "$ErrorPath\LatestErrors.txt"
        Write-Host "cleaing"
    }
    foreach ($file in $files) {
        if (![System.IO.File]::Exists($file)) {
            Write-Host "file with path $file doesn't exist"
        }
        else {
            New-Item -Path $ErrorPath -Name "temp.txt" -ItemType "file"
            Get-Content -Path "$file" -Raw | ForEach-Object -Process { $_ -replace "- `r`n", '- ' } | Add-Content -Path "$ErrorPath\temp.txt"
            $content1 = Get-ChildItem -path "$ErrorPath\temp.txt" -Recurse | Select-String -Pattern "error" -AllMatches | ForEach-Object { $_.Line }
            if ($content1.length -eq 0) {
                Write-Host "empty"
            } 
            else {
                Add-Content -path "$ErrorPath\LatestErrors.txt" -Value $file
            }	
            Add-Content -path "$ErrorPath\LatestErrors.txt" -Value $content1, "`n"
            Remove-Item "$ErrorPath\temp.txt"
        }
    }
}

Function AllEALogs {
    $LogPath = $x
    $EALogs1 = "$LogPath\TOBII_DYNAVOX_APPDATA\EYEASSIST\LOGS"
    $EALogs2 = "$LogPath\Logs\Eye Assist\Logs"

    #Creating folder
    $ErrorPath = "$LogPath\ErrorLogs"
    if (!(Test-Path "$ErrorPath")) {
        Write-Host "Creating ErrorLogs folder.."
        New-Item -Path "$ErrorPath" -ItemType Directory   
    }
    #Creating files
    if (!(Test-Path "$ErrorPath\EALogs.txt")) {
        New-Item -Path $ErrorPath -Name "EALogs.txt" -ItemType "file"
        Write-Host "creating file"
    } 
    else {
        Clear-Content -Path "$ErrorPath\EALogs.txt"
        Write-Host "cleaing"
    }

    if (Test-path $EALogs1) {
        $EAcontent = Get-ChildItem -Path $EALogs1 -Recurse | Sort-Object name -desc | Select-Object -expand Fullname
    } 
    elseif (Test-path $EALogs2) {
        $EAcontent = Get-ChildItem -Path $EALogs2 -Recurse | Sort-Object name -desc | Select-Object -expand Fullname
    }

    foreach ($NewEAContent in $EAcontent) {
        New-Item -Path $ErrorPath -Name "temp.txt" -ItemType "file"
        Get-Content -Path "$NewEAContent" -Raw | ForEach-Object -Process { $_ -replace "- `r`n", '- ' } | Add-Content -Path "$ErrorPath\temp.txt"
        $content2 = Get-ChildItem -path "$ErrorPath\temp.txt" -Recurse | Select-String -Pattern "error" -AllMatches | ForEach-Object { $_.Line }
        if ($content2.length -eq 0) {
            Write-Host "empty"
        } 
        else {
            Add-Content -path "$ErrorPath\EALogs.txt" -Value $NewEAContent
        }	
        Add-Content -path "$ErrorPath\EALogs.txt" -Value $content2, "`n"
        Remove-Item "$ErrorPath\temp.txt"
    }
}

Function AllTTechLogs {
    $LogPath = $x
    #Creating folder
    $ErrorPath = "$LogPath\ErrorLogs"
    if (!(Test-Path "$ErrorPath")) {
        Write-Host "Creating ErrorLogs folder.."
        New-Item -Path "$ErrorPath" -ItemType Directory   
    }
    #Creating files
    $ServiceLog = "$ErrorPath\ServiceLog.txt"
    $PR_logs = "$ErrorPath\Runtime_logs.txt"
    $InteractionLog = "$ErrorPath\InteractionLog.txt"
    $ServerLog = "$ErrorPath\ServerLog.txt"
    $ConfigurationLog = "$ErrorPath\ConfigurationLog.txt"
    $TrayLog = "$ErrorPath\TrayLog.txt"

    $files = @("$ServiceLog", "$PR_logs", "$InteractionLog", "$ServerLog", "$ConfigurationLog", "$TrayLog")
    foreach ($path in $files) {
        if (!(Test-path $path)) {
            New-Item -ItemType File -Path $path
        }
        else {
            Clear-Content -Path "$path"
        }
    }

    $Servicecontent = Get-ChildItem -Include ServiceLog*.* -Path $LogPath -Recurse  | Sort-Object name -desc | Select-Object -expand Fullname
    $file = $files[0]
    foreach ($NewServicecontent in $Servicecontent) {
        New-Item -Path $ErrorPath -Name "temp.txt" -ItemType "file"
        Get-Content -LiteralPath "$NewServicecontent" -Raw | ForEach-Object -Process { $_ -replace "- `r`n", '- ' } | Add-Content -Path "$ErrorPath\temp.txt"
        $content3 = Get-ChildItem -path "$ErrorPath\temp.txt" -Recurse | Select-String -Pattern "error" -AllMatches | ForEach-Object { $_.Line }
        if ($content3.length -eq 0) { 
            Write-Host "empty"
        } 
        else {
            Add-Content -path $file -Value $NewServicecontent
        }	
        Add-Content -path $file -value $content3, "`n"
        Remove-Item "$ErrorPath\temp.txt"
    }

    $PRcontent = Get-ChildItem -Include pr_log*.* -Path $LogPath -Recurse | Sort-Object name -desc | Select-Object -expand Fullname
    $file = $files[1]
    foreach ($NewPRContent in $PRcontent) {
        New-Item -Path $ErrorPath -Name "temp.txt" -ItemType "file"
        Get-Content -Path "$NewPRContent" -Raw | ForEach-Object -Process { $_ -replace "- `r`n", '- ' } | Add-Content -Path "$ErrorPath\temp.txt"
        $content4 = Get-ChildItem -path "$ErrorPath\temp.txt" -Recurse | Select-String -Pattern "error" -AllMatches | ForEach-Object { $_.Line }
        if ($content4.length -eq 0) { 
            Write-Host "empty"
        } 
        else {
            Add-Content -path $file -Value $NewPRContent
        }	
        Add-Content -path $file -value $content4, "`n"
        Remove-Item "$ErrorPath\temp.txt"
    }

    $Interactioncontent = Get-ChildItem -Include InteractionLog*.* -Path $LogPath -Recurse | Sort-Object name -desc | Select-Object -expand Fullname
    $file = $files[2]
    foreach ($NewInteractioncontent in $Interactioncontent) {
        New-Item -Path $ErrorPath -Name "temp.txt" -ItemType "file"
        Get-Content -LiteralPath "$NewInteractioncontent" -Raw | ForEach-Object -Process { $_ -replace "- `r`n", '- ' } | Add-Content -Path "$ErrorPath\temp.txt"
        $content5 = Get-ChildItem -path "$ErrorPath\temp.txt" -Recurse | Select-String -Pattern "error" -AllMatches | ForEach-Object { $_.Line }    
        if ($content5.length -eq 0) { 
            Write-Host "empty"
        } 
        else {
            Add-Content -path $file -Value $NewInteractioncontent

        }	
        Add-Content $file -value $content5, "`n"
        Remove-Item "$ErrorPath\temp.txt"
    }

    $Servercontent = Get-ChildItem -Include ServerLog*.* -Path $LogPath -Recurse | Sort-Object name -desc | Select-Object -expand Fullname
    $file = $files[3]
    foreach ($NewServercontent in $Servercontent) {
        New-Item -Path $ErrorPath -Name "temp.txt" -ItemType "file"
        Get-Content -LiteralPath "$NewServercontent" -Raw | ForEach-Object -Process { $_ -replace "- `r`n", '- ' } | Add-Content -Path "$ErrorPath\temp.txt"
        $content6 = Get-ChildItem -path "$ErrorPath\temp.txt" -Recurse | Select-String -Pattern "error" -AllMatches | ForEach-Object { $_.Line } 
        if ($content6.length -eq 0) { 
            Write-Host "empty"
        } 
        else {
            Add-Content -path $file -Value $NewServercontent
        }	
        Add-Content $file -value $content6, "`n"
        Remove-Item "$ErrorPath\temp.txt"
    }

    $Configcontent = Get-ChildItem -Include ConfigurationLog*.* -Path $LogPath -Recurse | Sort-Object name -desc | Select-Object -expand Fullname
    $file = $files[4]
    foreach ($NewConfigcontent in $Configcontent) {
        New-Item -Path $ErrorPath -Name "temp.txt" -ItemType "file"
        Get-Content -LiteralPath "$NewConfigcontent" -Raw | ForEach-Object -Process { $_ -replace "- `r`n", '- ' } | Add-Content -Path "$ErrorPath\temp.txt"
        $content7 = Get-ChildItem -path "$ErrorPath\temp.txt" -Recurse | Select-String -Pattern "error" -AllMatches | ForEach-Object { $_.Line } 
        if ($content7.length -eq 0) { 
            Write-Host "empty"
        } 
        else {
            Add-Content -path $file -Value $NewConfigcontent
        }	
        Add-Content $file -value $content7, "`n"
        Remove-Item "$ErrorPath\temp.txt"
    }

    $Traycontent = Get-ChildItem -Include Tray*.* -Path $LogPath -Recurse | Sort-Object name -desc | Select-Object -expand Fullname
    $file = $files[5]
    foreach ($NewTraycontent in $Traycontent) {
        New-Item -Path $ErrorPath -Name "temp.txt" -ItemType "file"
        Get-Content -LiteralPath "$NewTraycontent" -Raw | ForEach-Object -Process { $_ -replace "- `r`n", '- ' } | Add-Content -Path "$ErrorPath\temp.txt"
        $content8 = Get-ChildItem -path "$ErrorPath\temp.txt" -Recurse | Select-String -Pattern "error" -AllMatches | ForEach-Object { $_.Line } 
        if ($content8.length -eq 0) { 
            Write-Host "empty"
        } 
        else {
            Add-Content -path $file -Value $NewTraycontent
        }	
        Add-Content $file -value $content8, "`n"
        Remove-Item "$ErrorPath\temp.txt"
    }
}

Function InstallerLogs {
    $LogPath = $x
    $InstallerLogs = "$LogPath\TOBII_INSTALLER_LOGS\TEMP"
    $ErrorPath = "$LogPath\ErrorLogs"
    if (!(Test-Path "$ErrorPath")) {
        Write-Host "Creating ErrorLogs folder.."
        New-Item -Path "$ErrorPath" -ItemType Directory   
    }
    if (!(Test-Path "$ErrorPath\InstallerError.txt")) {
        $ErrorFile = New-Item -Path $ErrorPath -Name "InstallerError.txt" -ItemType "file"
        Write-Host "creating file"
    }
    else {
        Clear-Content -Path "$ErrorPath\InstallerError.txt"
        Write-Host "cleaing"
    }
    if (Test-path $InstallerLogs) { 
        $Installercontent = Get-ChildItem -Path $InstallerLogs -Recurse -File | Sort-Object name -desc | Select-Object -expand Fullname
        foreach ($NewInstallercontent in $Installercontent) {
            New-Item -Path $ErrorPath -Name "temp.txt" -ItemType "file"
            Get-Content -Path "$NewInstallercontent" -Raw | ForEach-Object -Process { $_ -replace "- `r`n", '- ' } | Add-Content -Path "$ErrorPath\temp.txt"
            $content9 = Get-ChildItem -path "$ErrorPath\temp.txt" -Recurse | Select-String -Pattern "error" -AllMatches | ForEach-Object { $_.Line }
            if ($content9.length -eq 0) { 
                Write-Host "empty"
            } 
            else {
                Add-Content -path $ErrorFile -Value $NewInstallercontent
            }	
            add-Content $ErrorFile -value $content9, "`n"
            Remove-Item "$ErrorPath\temp.txt"	
        }
    }
    else { Write-Host "Files are not existed" }
}

Function OtherLogs {
    $LogPath = $x
    if ((Get-Item $LogPath) -is [System.IO.DirectoryInfo]) {
        #Creating folder
        $ErrorPath = "$LogPath\ErrorLogs"
        if (!(Test-Path "$ErrorPath")) {
            Write-Host "Creating ErrorLogs folder.."
            New-Item -Path "$ErrorPath" -ItemType Directory   
        }
        #Creating files
        if (!(Test-Path "$ErrorPath\errorlogs.txt")) {
            New-Item -Path $ErrorPath -Name "errorlogs.txt" -ItemType "file"
            Write-Host "creating file"
        }
        else {
            Clear-Content -Path "$ErrorPath\errorlogs.txt"
            Write-Host "cleaing"
        }
        $Othercontent = Get-ChildItem -Path $LogPath -file | Sort-Object name -desc | Select-Object -expand Fullname
        foreach ($NewOthercontent in $Othercontent) {
            New-Item -Path $ErrorPath -Name "temp.txt" -ItemType "file"
            Get-Content -Path "$NewOthercontent" -Raw | ForEach-Object -Process { $_ -replace "- `r`n", '- ' } | Add-Content -Path "$ErrorPath\temp.txt"
            $content10 = Get-ChildItem -path "$ErrorPath\temp.txt" -Recurse | Select-String -Pattern "error" -AllMatches | ForEach-Object { $_.Line }
            if ($content10.length -eq 0) {
                Write-Host "empty"
            } 
            else {
                Add-Content -path "$ErrorPath\errorlogs.txt" -Value $NewOthercontent
            }	
            Add-Content -path "$ErrorPath\errorlogs.txt" -Value $content10, "`n"
            Remove-Item "$ErrorPath\temp.txt"
        }

    } else {
        $LogPath2 = Split-Path -Path $LogPath
        $ErrorPath = "$LogPath2\ErrorLogs"
        if (!(Test-Path "$ErrorPath")) {
            Write-Host "Creating ErrorLogs folder.."
            New-Item -Path "$ErrorPath" -ItemType Directory   
        }
        #Creating files
        if (!(Test-Path "$ErrorPath\errorlogs.txt")) {
            New-Item -Path $ErrorPath -Name "errorlogs.txt" -ItemType "file"
            Write-Host "creating file"
        }
        else {
            Clear-Content -Path "$ErrorPath\errorlogs.txt"
            Write-Host "cleaing"
        }
        New-Item -Path $ErrorPath -Name "temp.txt" -ItemType "file"
        Get-Content -Path "$LogPath" -Raw | ForEach-Object -Process { $_ -replace "- `r`n", '- ' } | Add-Content -Path "$ErrorPath\temp.txt"
        $content11 = Get-ChildItem -path "$ErrorPath\temp.txt" -Recurse | Select-String -Pattern "error" -AllMatches | ForEach-Object { $_.Line }
        if ($content11.length -eq 0) {
            Write-Host "empty"
        } 
        else {
            Add-Content -path "$ErrorPath\errorlogs.txt" -Value $LogPath
        }	
        Add-Content -path "$ErrorPath\errorlogs.txt" -Value $content11, "`n"
        Remove-Item "$ErrorPath\temp.txt"
    }
}

Function TimeStamp {
    $LogPath = $x
    $date = $x3
	
    $ErrorPath = "$LogPath\ErrorLogs"
    $EALogs1 = "$LogPath\TOBII_DYNAVOX_APPDATA\EYEASSIST\LOGS"
    $EALogs2 = "$LogPath\Logs\Eye Assist\Logs"
    $InstallerLogs = "$LogPath\TOBII_INSTALLER_LOGS\TEMP"
    #Creating folder
    if (!(Test-Path "$ErrorPath")) {
        Write-Host "Creating ErrorLogs folder.."
        New-Item -Path "$ErrorPath" -ItemType Directory   
    }
    if ($date -match ":") {
        $newDate = $date -replace ":" , "."
    }
    else { $newDate = $date }
    if (!(Test-Path "$ErrorPath\$newDate.txt")) {
        $ErrorFile = New-Item -Path $ErrorPath -Name "$newDate.txt" -ItemType "file"
        Write-Host "creating file"
    } 
    else {
        Clear-Content -Path "$ErrorPath\$newDate.txt"
        Write-Host "cleaing"
    }

    $Servicecontent1 = Get-ChildItem -Include ServiceLog*.* -Path $LogPath -Recurse  | Sort-Object name -desc | Select-Object -expand Fullname
    foreach ($NewServicecontent1 in $Servicecontent1) {
        New-Item -Path $ErrorPath -Name "temp.txt" -ItemType "file"
        Get-Content -Path "$NewServicecontent1" -Raw | ForEach-Object -Process { $_ -replace "- `r`n", '- ' } | Add-Content -Path "$ErrorPath\temp.txt"
        $content12 = Get-ChildItem -path "$ErrorPath\temp.txt" -Recurse | Select-String -Pattern "$date" -AllMatches | ForEach-Object { $_.Line }
        if ($content12.length -eq 0) { 
            Write-Host "empty"
        } 
        else {
            Add-Content $ErrorFile -Value $NewServicecontent1
        }	
        Add-Content $ErrorFile -value $content12, "`n"
        Remove-Item "$ErrorPath\temp.txt"
    }

    $PRcontent1 = Get-ChildItem -Include pr_log*.* -Path $LogPath -Recurse | Sort-Object name -desc | Select-Object -expand Fullname
    foreach ($NewPRcontent1 in $PRcontent1) {
        New-Item -Path $ErrorPath -Name "temp.txt" -ItemType "file"
        Get-Content -Path "$NewPRcontent1" -Raw | ForEach-Object -Process { $_ -replace "- `r`n", '- ' } | Add-Content -Path "$ErrorPath\temp.txt"
        $content13 = Get-ChildItem -path "$ErrorPath\temp.txt" -Recurse | Select-String -Pattern "$date" -AllMatches | ForEach-Object { $_.Line }
        if ($content13.length -eq 0) { 
            Write-Host "empty"
        } 
        else {
            Add-Content $ErrorFile -Value $NewPRcontent1
        }
        add-Content $ErrorFile -value $content13, "`n"
        Remove-Item "$ErrorPath\temp.txt"
    }

    $Interactioncontent2 = Get-ChildItem -Include InteractionLog*.* -Path $LogPath -Recurse | Sort-Object name -desc | Select-Object -expand Fullname
    foreach ($NewInteractioncontent2 in $Interactioncontent2) {
        New-Item -Path $ErrorPath -Name "temp.txt" -ItemType "file"
        Get-Content -LiteralPath "$NewInteractioncontent2" -Raw | ForEach-Object -Process { $_ -replace "- `r`n", '- ' } | Add-Content -Path "$ErrorPath\temp.txt"
        $content14 = Get-ChildItem -path "$ErrorPath\temp.txt" -Recurse | Select-String -Pattern "$date" -AllMatches | ForEach-Object { $_.Line }    
        if ($content14.length -eq 0) { 
            Write-Host "empty"
        } 
        else {
            Add-Content -path $ErrorFile -Value $NewInteractioncontent2
        }	
        Add-Content $ErrorFile -value $content14, "`n"
        Remove-Item "$ErrorPath\temp.txt"
    }

    $Servercontent2 = Get-ChildItem -Include ServerLog*.* -Path $LogPath -Recurse | Sort-Object name -desc | Select-Object -expand Fullname
    foreach ($NewServercontent2 in $Servercontent2) {
        New-Item -Path $ErrorPath -Name "temp.txt" -ItemType "file"
        Get-Content -LiteralPath "$NewServercontent2" -Raw | ForEach-Object -Process { $_ -replace "- `r`n", '- ' } | Add-Content -Path "$ErrorPath\temp.txt"
        $content15 = Get-ChildItem -path "$ErrorPath\temp.txt" -Recurse | Select-String -Pattern "$date" -AllMatches | ForEach-Object { $_.Line } 
        if ($content15.length -eq 0) { 
            Write-Host "empty"
        } 
        else {
            Add-Content -path $ErrorFile -Value $NewServercontent2
        }	
        Add-Content $ErrorFile -value $content15, "`n"
        Remove-Item "$ErrorPath\temp.txt"
    }

    $Configcontent2 = Get-ChildItem -Include ConfigurationLog*.* -Path $LogPath -Recurse | Sort-Object name -desc | Select-Object -expand Fullname
    foreach ($NewConfigcontent2 in $Configcontent2) {
        New-Item -Path $ErrorPath -Name "temp.txt" -ItemType "file"
        Get-Content -LiteralPath "$NewConfigcontent2" -Raw | ForEach-Object -Process { $_ -replace "- `r`n", '- ' } | Add-Content -Path "$ErrorPath\temp.txt"
        $content16 = Get-ChildItem -path "$ErrorPath\temp.txt" -Recurse | Select-String -Pattern "$date" -AllMatches | ForEach-Object { $_.Line } 
        if ($content16.length -eq 0) { 
            Write-Host "empty"
        } 
        else {
            Add-Content -path $ErrorFile -Value $NewConfigcontent2
        }	
        Add-Content $ErrorFile -value $content16, "`n"
        Remove-Item "$ErrorPath\temp.txt"
    }

    $Traycontent1 = Get-ChildItem -Include Tray*.* -Path $LogPath -Recurse | Sort-Object name -desc | Select-Object -expand Fullname
    foreach ($NewTraycontent1 in $Traycontent1) {
        New-Item -Path $ErrorPath -Name "temp.txt" -ItemType "file"
        Get-Content -LiteralPath "$NewTraycontent1" -Raw | ForEach-Object -Process { $_ -replace "- `r`n", '- ' } | Add-Content -Path "$ErrorPath\temp.txt"
        $content17 = Get-ChildItem -path "$ErrorPath\temp.txt" -Recurse | Select-String -Pattern "$date" -AllMatches | ForEach-Object { $_.Line } 
        if ($content17.length -eq 0) { 
            Write-Host "empty"
        } 
        else {
            Add-Content -path $ErrorFile -Value $NewTraycontent1
        }	
        Add-Content $ErrorFile -value $content17, "`n"
        Remove-Item "$ErrorPath\temp.txt"
    }

    if (Test-path $EALogs1) {
        $EAcontent1 = Get-ChildItem -Path $EALogs1 -Recurse | Sort-Object name -desc | Select-Object -expand Fullname
    } 
    elseif (Test-path $EALogs2) {
        $EAcontent1 = Get-ChildItem -Path $EALogs2 -Recurse | Sort-Object name -desc | Select-Object -expand Fullname
    }
    foreach ($NewEAcontent1 in $EAcontent1) {
        New-Item -Path $ErrorPath -Name "temp.txt" -ItemType "file"
        Get-Content -Path "$NewEAcontent1" -Raw | ForEach-Object -Process { $_ -replace "- `r`n", '- ' } | Add-Content -Path "$ErrorPath\temp.txt"
        $content18 = Get-ChildItem -path "$ErrorPath\temp.txt" -Recurse | Select-String -Pattern "$date" -AllMatches | ForEach-Object { $_.Line }
        if ($content18.length -eq 0) {
            Write-Host "empty"
        } 
        else {
            Add-Content -path $ErrorFile -Value $NewEAcontent1
        }	
        Add-Content -path $ErrorFile -Value $content18, "`n"
        Remove-Item "$ErrorPath\temp.txt"
    }

    if (Test-path $InstallerLogs) { 
        $Installercontent1 = Get-ChildItem -Path $InstallerLogs -Recurse -File | Sort-Object name -desc | Select-Object -expand Fullname
        foreach ($NewInstallercontent1 in $Installercontent1) {
            New-Item -Path $ErrorPath -Name "temp.txt" -ItemType "file"
            Get-Content -Path "$NewInstallercontent1" -Raw | ForEach-Object -Process { $_ -replace "- `r`n", '- ' } | Add-Content -Path "$ErrorPath\temp.txt"
            $content19 = Get-ChildItem -path "$ErrorPath\temp.txt" -Recurse | Select-String -Pattern "$date" -AllMatches | ForEach-Object { $_.Line }
            if ($content19.length -eq 0) { 
                Write-Host "empty"
            } 
            else {
                Add-Content -path $file -Value $NewInstallercontent1
            }	
            add-Content $ErrorFile -value $content19, "`n"
            Remove-Item "$ErrorPath\temp.txt"	
        }
    }
    else { Write-Host "Files are not existed" }

    $CCcontent = Get-ChildItem -Include ComputerControl*.* -Path $LogPath -Recurse | Sort-Object name -desc | Select-Object -expand Fullname
    foreach ($NewCCcontent in $CCcontent) {
        New-Item -Path $ErrorPath -Name "temp.txt" -ItemType "file"
        Get-Content -Path "$NewCCcontent" -Raw | ForEach-Object -Process { $_ -replace "- `r`n", '- ' } | Add-Content -Path "$ErrorPath\temp.txt"
        $content20 = Get-ChildItem -path "$ErrorPath\temp.txt" -Recurse | Select-String -Pattern "$date" -AllMatches | ForEach-Object { $_.Line }
        if ($content20.length -eq 0) {
            Write-Host "empty"
        } 
        else {
            Add-Content -path $ErrorFile -Value $NewCCcontent
        }	
        Add-Content -path $ErrorFile -Value $content20, "`n"
        Remove-Item "$ErrorPath\temp.txt"
    }
}

Function TimeStampBetween {

    $LogPath = $x
    $ErrorPath = "$LogPath\ErrorLogs"
    $EALogs1 = "$LogPath\TOBII_DYNAVOX_APPDATA\EYEASSIST\LOGS"
    $EALogs2 = "$LogPath\Logs\Eye Assist\Logs"
    $InstallerLogs = "$LogPath\TOBII_INSTALLER_LOGS\TEMP"
    #$date = "2020-11-22"

    $start = Get-Date "$x4"
    $end = Get-Date "$x5"

  
    # Pattern explaination # ^ matches the begginning of each line # \d matches a decimal character
    # {4},{2},{3} repeats the previous character # so \d{4} matches any four numerals # / and : are literally / and :
    # a period is a special regex character so it needs escaped \.
    $pattern = "^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\."

    #Creating folder
    if (!(Test-Path "$ErrorPath")) {
        Write-Host "Creating ErrorLogs folder.." 
        $NewFolder = New-Item -Path "$ErrorPath" -ItemType Directory  
    }

    if ($start -match ":") {
        $newStart = $start -replace ":" , "."
    } else { $newstart = $start }

    if ($end -match ":") {
        $newEnd = $end -replace ":" , "."
    } else { $newEnd = $end }

    $textfile = "$newStart - $newEnd"
    if (!(Test-Path "$ErrorPath\$textfile.txt")) {
        $NewItem = New-Item -Path $ErrorPath -Name "$textfile.txt" -ItemType "file"
        Write-Host "creating file"
    } elseif (Test-Path "$ErrorPath\$textfile.txt") {
        Clear-Content -Path "$ErrorPath\$newStart - $newEnd.txt"
        Write-Host "cleaing"
    }

    $Servicecontent2 = Get-ChildItem -Include ServiceLog*.* -Path $LogPath -Recurse  | Sort-Object name -desc | Where-Object fullname -NotLike "$ErrorPath\ServiceLog.txt" | Select-Object -expand Fullname
    foreach ($NewServicecontent2 in $Servicecontent2) {
        $newtemp = New-Item -Path $ErrorPath -Name "temp.txt" -ItemType "file"
        Get-Content -Path "$NewServicecontent2" -Raw | ForEach-Object -Process { $_ -replace "- `r`n", '- ' -replace ",", "." } | Add-Content -Path "$ErrorPath\temp.txt"
        $content21 = Get-ChildItem -path "$ErrorPath\temp.txt" -Recurse #| Select-String -Pattern "$date" -AllMatches | ForEach-Object { $_.Line }
        $entries = $content21 | Select-String -Pattern $pattern | ForEach-Object {
            [pscustomobject]@{ 
                'Date' = [datetime]::Parse($_.Matches[0].Value) 
                'Line' = $_.LineNumber 
                'Text' = $_.Line
            }
        }
        $filtered = $entries | Where-Object { $_.Date -ge $start -and $_.Date -le $end } | Sort-Object Date 
        if ($filtered) {
            $first = $filtered[0].Line - 1 
            $last = $filtered[-1].Line - 1 
            $content21[$first..$last] 
        }
        if ($filtered.length -eq 0) { 
            Write-Host "empty"
        } 
        else {
            Add-Content "$ErrorPath\$textfile.txt" -Value $NewServicecontent2
        }
        Add-Content "$ErrorPath\$textfile.txt" -value $filtered.text, "`n"
        Remove-Item "$ErrorPath\temp.txt"
    }

    $PRcontent2 = Get-ChildItem -Include pr_log*.* -Path $LogPath -Recurse | Sort-Object name -desc | Where-Object fullname -NotLike "$ErrorPath\pr_log.txt" | Select-Object -expand Fullname
    foreach ($NewPRcontent2 in $PRcontent2) {
        New-Item -Path $ErrorPath -Name "temp.txt" -ItemType "file"
        Get-Content -Path "$NewPRcontent2" -Raw | ForEach-Object -Process { $_ -replace "- `r`n", '- ' -replace ",", "." } | Add-Content -Path "$ErrorPath\temp.txt"
        $content22 = Get-ChildItem -path "$ErrorPath\temp.txt" -Recurse
        $entries = $content22 | Select-String -Pattern $pattern | ForEach-Object {
            [pscustomobject]@{ 
                'Date' = [datetime]::Parse($_.Matches[0].Value) 
                'Line' = $_.LineNumber 
                'Text' = $_.Line
            }
        }
        $filtered = $entries | Where-Object { $_.Date -ge $start -and $_.Date -le $end } | Sort-Object Date 
        if ($filtered) {
            $first = $filtered[0].Line - 1 
            $last = $filtered[-1].Line - 1 
            $content22[$first..$last] 
        }
        if ($filtered.length -eq 0) { 
            Write-Host "empty"
        } 
        else {
            Add-Content "$ErrorPath\$textfile.txt" -Value $NewPRcontent2
        }
        Add-Content "$ErrorPath\$textfile.txt" -value $filtered.text, "`n"
        Remove-Item "$ErrorPath\temp.txt"
    }

    $Interactioncontent2 = Get-ChildItem -Include InteractionLog*.* -Path $LogPath -Recurse | Sort-Object name -desc | Where-Object fullname -NotLike "$ErrorPath\InteractionLog.txt" | Select-Object -expand Fullname
    foreach ($NewInteractioncontent2 in $Interactioncontent2) {
        $NewItem = New-Item -Path $ErrorPath -Name "temp.txt" -ItemType "file"
        Get-Content -LiteralPath "$NewInteractioncontent2" -Raw | ForEach-Object -Process { $_ -replace "- `r`n", '- ' -replace ",", "." } | Add-Content -Path "$ErrorPath\temp.txt"
        $content23 = Get-ChildItem -path "$ErrorPath\temp.txt" -Recurse
        $entries = $content23 | Select-String -Pattern $pattern | ForEach-Object {
            [pscustomobject]@{ 
                'Date' = [datetime]::Parse($_.Matches[0].Value) 
                'Line' = $_.LineNumber 
                'Text' = $_.Line
            }
        }
        $filtered = $entries | Where-Object { $_.Date -ge $start -and $_.Date -le $end } | Sort-Object Date 
        if ($filtered) {
            $first = $filtered[0].Line - 1 
            $last = $filtered[-1].Line - 1 
            $content23[$first..$last] 
        }
        if ($filtered.length -eq 0) { 
            Write-Host "empty"
        } 
        else {
            Add-Content "$ErrorPath\$textfile.txt" -Value $NewInteractioncontent2
        }	
        Add-Content "$ErrorPath\$textfile.txt" -value $filtered.text, "`n"
        Remove-Item "$ErrorPath\temp.txt"
    }

    $Servercontent2 = Get-ChildItem -Include ServerLog*.* -Path $LogPath -Recurse | Sort-Object name -desc | Where-Object fullname -NotLike "$ErrorPath\ServerLog.txt" | Select-Object -expand Fullname
    foreach ($NewServercontent2 in $Servercontent2) {
        $NewItem = New-Item -Path $ErrorPath -Name "temp.txt" -ItemType "file"
        Get-Content -LiteralPath "$NewServercontent2" -Raw | ForEach-Object -Process { $_ -replace "- `r`n", '- ' -replace ",", "." } | Add-Content -Path "$ErrorPath\temp.txt"
        $content24 = Get-ChildItem -path "$ErrorPath\temp.txt" -Recurse
        $entries = $content24 | Select-String -Pattern $pattern | ForEach-Object {
            [pscustomobject]@{ 
                'Date' = [datetime]::Parse($_.Matches[0].Value) 
                'Line' = $_.LineNumber 
                'Text' = $_.Line
            }
        }
        $filtered = $entries | Where-Object { $_.Date -ge $start -and $_.Date -le $end } | Sort-Object Date 
        if ($filtered) {
            $first = $filtered[0].Line - 1 
            $last = $filtered[-1].Line - 1 
            $content24[$first..$last] 
        }
        if ($filtered.length -eq 0) { 
            Write-Host "empty"
        } 
        else {
            Add-Content "$ErrorPath\$textfile.txt" -Value $NewServercontent2
        }	
        Add-Content "$ErrorPath\$textfile.txt" -value $filtered.text, "`n"
        Remove-Item "$ErrorPath\temp.txt"
    }

    $Configcontent2 = Get-ChildItem -Include ConfigurationLog*.* -Path $LogPath -Recurse | Sort-Object name -desc | Where-Object fullname -NotLike "$ErrorPath\ConfigurationLog.txt" | Select-Object -expand Fullname
    foreach ($NewConfigcontent2 in $Configcontent2) {
	    $NewItem = New-Item -Path $ErrorPath -Name "temp.txt" -ItemType "file"
	    Get-Content -LiteralPath "$NewConfigcontent2" -Raw | ForEach-Object -Process { $_ -replace "- `r`n", '- ' -replace ",", "." } | Add-Content -Path "$ErrorPath\temp.txt"
	    $content25 = Get-ChildItem -path "$ErrorPath\temp.txt" -Recurse
	    $entries = $content25 | Select-String -Pattern $pattern | ForEach-Object {
		    [pscustomobject]@{ 
			    'Date' = [datetime]::Parse($_.Matches[0].Value) 
			    'Line' = $_.LineNumber 
			    'Text' = $_.Line
		    }
	    }
	    $filtered = $entries | Where-Object { $_.Date -ge $start -and $_.Date -le $end } | Sort-Object Date 
	    if ($filtered) {
		    $first = $filtered[0].Line - 1 
		    $last = $filtered[-1].Line - 1 
		    $content25[$first..$last] 
	    }
	    if ($filtered.length -eq 0) { 
		    Write-Host "empty"
	    } 
	    else {
		    Add-Content "$ErrorPath\$textfile.txt" -Value $NewConfigcontent2
	    }	
	    Add-Content "$ErrorPath\$textfile.txt" -value $filtered.text, "`n"
	    Remove-Item "$ErrorPath\temp.txt"
    }

    $Traycontent2 = Get-ChildItem -Include Tray*.* -Path $LogPath -Recurse | Sort-Object name -desc | Where-Object fullname -NotLike "$ErrorPath\Tray.txt" | Select-Object -expand Fullname
    foreach ($NewTraycontent2 in $Traycontent2) {
	    $NewItem = New-Item -Path $ErrorPath -Name "temp.txt" -ItemType "file"
	    Get-Content -LiteralPath "$NewTraycontent2" -Raw | ForEach-Object -Process { $_ -replace "- `r`n", '- ' -replace ",", "." } | Add-Content -Path "$ErrorPath\temp.txt"
	    $content26 = Get-ChildItem -path "$ErrorPath\temp.txt" -Recurse
	    $entries = $content26 | Select-String -Pattern $pattern | ForEach-Object {
		    [pscustomobject]@{ 
			    'Date' = [datetime]::Parse($_.Matches[0].Value) 
			    'Line' = $_.LineNumber 
			    'Text' = $_.Line
		    }
	    }
	    $filtered = $entries | Where-Object { $_.Date -ge $start -and $_.Date -le $end } | Sort-Object Date 
	    if ($filtered) {
		    $first = $filtered[0].Line - 1 
		    $last = $filtered[-1].Line - 1 
		    $content26[$first..$last] 
	    }
	    if ($filtered.length -eq 0) { 
		    Write-Host "empty"
	    } 
	    else {
		    Add-Content "$ErrorPath\$textfile.txt" -Value $NewTraycontent2
	    }	
	    Add-Content "$ErrorPath\$textfile.txt" -value $filtered.text, "`n"
	    Remove-Item "$ErrorPath\temp.txt"
    }

    if (Test-path $EALogs1) {
	    $EAcontent2 = Get-ChildItem -Path $EALogs1 -Recurse | Sort-Object name -desc | Select-Object -expand Fullname
    } 
    elseif (Test-path $EALogs2) {
	    $EAcontent2 = Get-ChildItem -Path $EALogs2 -Recurse | Sort-Object name -desc | Select-Object -expand Fullname
    }

    foreach ($NewEAcontent2 in $EAcontent2) {
	    $NewItem = New-Item -Path $ErrorPath -Name "temp.txt" -ItemType "file"
	    Get-Content -Path "$NewEAcontent2" -Raw | ForEach-Object -Process { $_ -replace "- `r`n", '- ' -replace ",", "." } | Add-Content -Path "$ErrorPath\temp.txt"
	    $content27 = Get-ChildItem -path "$ErrorPath\temp.txt" -Recurse
	    $entries = $content27 | Select-String -Pattern $pattern | ForEach-Object {
		    [pscustomobject]@{ 
			    'Date' = [datetime]::Parse($_.Matches[0].Value) 
			    'Line' = $_.LineNumber 
			    'Text' = $_.Line
		    }
	    }
	    $filtered = $entries | Where-Object { $_.Date -ge $start -and $_.Date -le $end } | Sort-Object Date 
	    if ($filtered) {
		    $first = $filtered[0].Line - 1 
		    $last = $filtered[-1].Line - 1 
		    $content27[$first..$last] 
	    }
	    if ($filtered.length -eq 0) {
		    Write-Host "empty"
	    } 
	    else {
		    Add-Content "$ErrorPath\$textfile.txt" -Value $NewEAcontent2
	    }	
	    Add-Content "$ErrorPath\$textfile.txt" -value $filtered.text, "`n"
	    Remove-Item "$ErrorPath\temp.txt"
    }

    if (Test-path $InstallerLogs) {
	    $Installercontent2 = Get-ChildItem -Path $InstallerLogs -Recurse -File | Sort-Object name -desc | Select-Object -expand Fullname
	    foreach ($NewInstallercontent2 in $Installercontent2) {
		    $NewItem = New-Item -Path $ErrorPath -Name "temp.txt" -ItemType "file"
		    Get-Content -Path "$NewInstallercontent2" -Raw | ForEach-Object -Process { $_ -replace "- `r`n", '- ' -replace ",", "." } | Add-Content -Path "$ErrorPath\temp.txt"
		    $content28 = Get-ChildItem -path "$ErrorPath\temp.txt" -Recurse
		    $entries = $content28 | Select-String -Pattern $pattern | ForEach-Object {
			    [pscustomobject]@{ 
				    'Date' = [datetime]::Parse($_.Matches[0].Value) 
				    'Line' = $_.LineNumber 
				    'Text' = $_.Line
			    }
		    }
		    $filtered = $entries | Where-Object { $_.Date -ge $start -and $_.Date -le $end } | Sort-Object Date 
		    if ($filtered) {
			    $first = $filtered[0].Line - 1 
			    $last = $filtered[-1].Line - 1 
			    $content28[$first..$last] 
		    }
		    if ($filtered.length -eq 0) { 
			    Write-Host "empty"
		    } 
		    else {
			    Add-Content "$ErrorPath\$textfile.txt" -Value $NewInstallercontent2
		    }	
		    Add-Content "$ErrorPath\$textfile.txt" -value $filtered.text, "`n"
		    Remove-Item "$ErrorPath\temp.txt"
	    }
    }
    else { Write-Host "Files are not existed" }

    $CCcontent2 = Get-ChildItem -Include ComputerControl*.* -Path $LogPath -Recurse | Sort-Object name -desc | Where-Object fullname -NotLike "$ErrorPath\ComputerControl.txt" | Select-Object -expand Fullname
    foreach ($NewCCcontent2 in $CCcontent2) {
	    $NewItem = New-Item -Path $ErrorPath -Name "temp.txt" -ItemType "file"
	    Get-Content -Path "$NewCCcontent2" -Raw | ForEach-Object -Process { $_ -replace "- `r`n", '- ' -replace ",", "." } | Add-Content -Path "$ErrorPath\temp.txt"
	    $content29 = Get-ChildItem -path "$ErrorPath\temp.txt" -Recurse
	    $entries = $content29 | Select-String -Pattern $pattern | ForEach-Object {
		    [pscustomobject]@{ 
			    'Date' = [datetime]::Parse($_.Matches[0].Value) 
			    'Line' = $_.LineNumber 
			    'Text' = $_.Line
		    }
	    }
	    $filtered = $entries | Where-Object { $_.Date -ge $start -and $_.Date -le $end } | Sort-Object Date 
	    if ($filtered) {
		    $first = $filtered[0].Line - 1 
		    $last = $filtered[-1].Line - 1 
		    $content29[$first..$last] 
	    }
	    if ($filtered.length -eq 0) {
		    Write-Host "empty"
	    } 
	    else {
		    Add-Content "$ErrorPath\$textfile.txt" -Value $NewCCcontent2
	    }	
	    Add-Content "$ErrorPath\$textfile.txt" -value $filtered.text, "`n"
	    Remove-Item "$ErrorPath\temp.txt"
    }

}

if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
    $x = $textBox.Text
    $x2 = $textBox2.Text
    $x3 = $textBox3.Text
    $x4 = $textBox4.Text
    $x5 = $textBox5.Text
    $x
    $x2
    $x3
    $x4
    $x5

    if ($x2 -match "1") { 
        GetETLatestErrorLogs
    }
    elseif ($x2 -match "2") { 
        AllEALogs
    }
    elseif ($x2 -match "3") { 
        AllTTechLogs
    }
    elseif ($x2 -match "4") { 
        InstallerLogs
    }
    elseif ($x2 -match "5") {
        OtherLogs
    }
    elseif (!($x2)) {
        if ("$x3") {
            TimeStamp
        }
        elseif("$x4" -and "$x5") {
            TimeStampBetween
        }
    }

}