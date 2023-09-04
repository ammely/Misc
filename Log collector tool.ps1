#_V0.4
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Error logs collector'
$form.Size = New-Object System.Drawing.Size(400, 300)
$form.StartPosition = 'CenterScreen'

$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = New-Object System.Drawing.Point(125, 230)
$okButton.Size = New-Object System.Drawing.Size(75, 23)
$okButton.Text = 'OK'
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $okButton
$form.Controls.Add($okButton)

$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Location = New-Object System.Drawing.Point(200, 230)
$cancelButton.Size = New-Object System.Drawing.Size(75, 23)
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
$label2.Size = New-Object System.Drawing.Size(350, 30)
$label2.Text = "ex. C:\Users\TobiiDynavox_SysInfo_xxxx `nResults will be saved in ErrorLogs at the same path as given above."
$form.Controls.Add($label2)

$label2 = New-Object System.Windows.Forms.Label
$label2.Location = New-Object System.Drawing.Point(10, 60)
$label2.Size = New-Object System.Drawing.Size(350, 70)
$label2.Text = "A. Which error logs are you looking for(choose only a number): `n1 Latest logs `n2 Eye Assist logs `n3 Driver software logs `n4 Driver installer logs"
$form.Controls.Add($label2)

$textBox2 = New-Object System.Windows.Forms.TextBox
$textBox2.Location = New-Object System.Drawing.Point(10, 130)
$textBox2.Size = New-Object System.Drawing.Size(100, 20)
$form.Controls.Add($textBox2)

$label3 = New-Object System.Windows.Forms.Label
$label3.Location = New-Object System.Drawing.Point(10, 155)
$label3.Size = New-Object System.Drawing.Size(350, 30)
$label3.Text = "B. Collect logs at specific time, format should be written as: `n2021-01-01 12:30"
$form.Controls.Add($label3)

$textBox3 = New-Object System.Windows.Forms.TextBox
$textBox3.Location = New-Object System.Drawing.Point(10, 185)
$textBox3.Size = New-Object System.Drawing.Size(100, 20)
$form.Controls.Add($textBox3)

$form.Topmost = $true

$form.Add_Shown( { $textBox.Select() })
$result = $form.ShowDialog()

if ($x -and $x2 -and $x3) {
    Clear-Variable x3
    Clear-Variable x2
    Clear-Variable x
}
if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
    $x = $textBox.Text
    $x2 = $textBox2.Text
    $x3 = $textBox3.Text
    $x
    $x2
    $x3
}

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
elseif (!($x2)) {
    if ("$x3") {
        TimeStamp
        Write-Host "HERE $x3"    
    }
    write-host("N/A")
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
            $content2 = Get-Content -Path "$file" -Raw | ForEach-Object -Process { $_ -replace "- `r`n", '- ' }
            Add-Content -Path "$ErrorPath\temp.txt" -Value $content2
            $content3 = Get-ChildItem -path "$ErrorPath\temp.txt" -Recurse | Select-String -Pattern "error" -AllMatches | ForEach-Object { $_.Line }
            if ($content3.length -eq 0) {
                Write-Host "empty"
            } 
            else {
                Add-Content -path "$ErrorPath\LatestErrors.txt" -Value $file
            }	
            Add-Content -path "$ErrorPath\LatestErrors.txt" -Value $content3, "`n"
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
        $content1 = Get-ChildItem -Path $EALogs1 -Recurse | Sort-Object name -desc | Select-Object -expand Fullname
    } 
    elseif (Test-path $EALogs2) {
        $content1 = Get-ChildItem -Path $EALogs2 -Recurse | Sort-Object name -desc | Select-Object -expand Fullname
    }

    foreach ($Content1 in $content1) {
        New-Item -Path $ErrorPath -Name "temp.txt" -ItemType "file"
        $content2 = Get-Content -Path "$Content1" -Raw | ForEach-Object -Process { $_ -replace "- `r`n", '- ' }
        Add-Content -Path "$ErrorPath\temp.txt" -Value $content2
        $content3 = Get-ChildItem -path "$ErrorPath\temp.txt" -Recurse | Select-String -Pattern "error" -AllMatches | ForEach-Object { $_.Line }
        if ($content3.length -eq 0) {
            Write-Host "empty"
        } 
        else {
            Add-Content -path "$ErrorPath\EALogs.txt" -Value $Content1
        }	
        Add-Content -path "$ErrorPath\EALogs.txt" -Value $content3, "`n"
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

    $content1 = Get-ChildItem -Include ServiceLog*.* -Path $LogPath -Recurse  | Sort-Object name -desc | Select-Object -expand Fullname
    $file = $files[0]
    foreach ($Content1 in $content1) {
        New-Item -Path $ErrorPath -Name "temp.txt" -ItemType "file"
        $content3 = Get-Content -LiteralPath "$Content1" -Raw | ForEach-Object -Process { $_ -replace "- `r`n", '- ' }
        Add-Content -Path "$ErrorPath\temp.txt" -Value $content3
        $content4 = Get-ChildItem -path "$ErrorPath\temp.txt" -Recurse | Select-String -Pattern "error" -AllMatches | ForEach-Object { $_.Line }
        if ($content4.length -eq 0) { 
            Write-Host "empty"
        } 
        else {
            Add-Content -path $file -Value $Content1
        }	
        Add-Content -path $file -value $content4, "`n"
        Remove-Item "$ErrorPath\temp.txt"
    }

    $content2 = Get-ChildItem -Include pr_log*.* -Path $LogPath -Recurse | Sort-Object name -desc | Select-Object -expand Fullname
    $file = $files[1]
    foreach ($Content2 in $content2) {
        New-Item -Path $ErrorPath -Name "temp.txt" -ItemType "file"
        $content7 = Get-Content -Path "$Content2" -Raw | ForEach-Object -Process { $_ -replace "- `r`n", '- ' }
        Add-Content -Path "$ErrorPath\temp.txt" -Value $content7
        $content8 = Get-ChildItem -path "$ErrorPath\temp.txt" -Recurse | Select-String -Pattern "error" -AllMatches | ForEach-Object { $_.Line }
        if ($content8.length -eq 0) { 
            Write-Host "empty"
        } 
        else {
            Add-Content -path $file -Value $Content2
        }	
        Add-Content -path $file -value $content8, "`n"
        Remove-Item "$ErrorPath\temp.txt"
    }

    $content3 = Get-ChildItem -Include InteractionLog*.* -Path $LogPath -Recurse | Sort-Object name -desc | Select-Object -expand Fullname
    $file = $files[2]
    foreach ($Content3 in $content3) {
        New-Item -Path $ErrorPath -Name "temp.txt" -ItemType "file"
        $content10 = Get-Content -LiteralPath "$Content3" -Raw | ForEach-Object -Process { $_ -replace "- `r`n", '- ' }
        Add-Content -Path "$ErrorPath\temp.txt" -Value $content10
        $content11 = Get-ChildItem -path "$ErrorPath\temp.txt" -Recurse | Select-String -Pattern "error" -AllMatches | ForEach-Object { $_.Line }    
        if ($content11.length -eq 0) { 
            Write-Host "empty"
        } 
        else {
            Add-Content -path $file -Value $Content3
        }	
        Add-Content $file -value $content11, "`n"
        Remove-Item "$ErrorPath\temp.txt"
    }

    $content4 = Get-ChildItem -Include ServerLog*.* -Path $LogPath -Recurse | Sort-Object name -desc | Select-Object -expand Fullname
    $file = $files[3]
    foreach ($Content4 in $content4) {
        New-Item -Path $ErrorPath -Name "temp.txt" -ItemType "file"
        $content13 = Get-Content -LiteralPath "$Content4" -Raw | ForEach-Object -Process { $_ -replace "- `r`n", '- ' }
        Add-Content -Path "$ErrorPath\temp.txt" -Value $content13
        $content14 = Get-ChildItem -path "$ErrorPath\temp.txt" -Recurse | Select-String -Pattern "error" -AllMatches | ForEach-Object { $_.Line } 
        if ($content14.length -eq 0) { 
            Write-Host "empty"
        } 
        else {
            Add-Content -path $file -Value $Content4
        }	
        Add-Content $file -value $content14, "`n"
        Remove-Item "$ErrorPath\temp.txt"
    }

    $content5 = Get-ChildItem -Include ConfigurationLog*.* -Path $LogPath -Recurse | Sort-Object name -desc | Select-Object -expand Fullname
    $file = $files[4]
    foreach ($Content5 in $content5) {
        New-Item -Path $ErrorPath -Name "temp.txt" -ItemType "file"
        $content15 = Get-Content -LiteralPath "$Content5" -Raw | ForEach-Object -Process { $_ -replace "- `r`n", '- ' }
        Add-Content -Path "$ErrorPath\temp.txt" -Value $content15
        $content13 = Get-ChildItem -path "$ErrorPath\temp.txt" -Recurse | Select-String -Pattern "error" -AllMatches | ForEach-Object { $_.Line } 
        if ($content13.length -eq 0) { 
            Write-Host "empty"
        } 
        else {
            Add-Content -path $file -Value $Content5
        }	
        Add-Content $file -value $content13, "`n"
        Remove-Item "$ErrorPath\temp.txt"
    }

    $content6 = Get-ChildItem -Include Tray*.* -Path $LogPath -Recurse | Sort-Object name -desc | Select-Object -expand Fullname
    $file = $files[5]
    foreach ($Content6 in $content6) {
        New-Item -Path $ErrorPath -Name "temp.txt" -ItemType "file"
        $content15 = Get-Content -LiteralPath "$Content6" -Raw | ForEach-Object -Process { $_ -replace "- `r`n", '- ' }
        Add-Content -Path "$ErrorPath\temp.txt" -Value $content15
        $content13 = Get-ChildItem -path "$ErrorPath\temp.txt" -Recurse | Select-String -Pattern "error" -AllMatches | ForEach-Object { $_.Line } 
        if ($content13.length -eq 0) { 
            Write-Host "empty"
        } 
        else {
            Add-Content -path $file -Value $Content6
        }	
        Add-Content $file -value $content13, "`n"
        Remove-Item "$ErrorPath\temp.txt"
    }

}

Function InstallerLogs {
    $LogPath = $x
    $LogPath = "C:\Users\aes\Desktop\SupportTools\TobiiDynavox_SysInfo_12_8_2020_11_07_15 AM"
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
        $content2 = Get-ChildItem -Path $InstallerLogs -Recurse -File | Sort-Object name -desc | Select-Object -expand Fullname
        foreach ($Content2 in $content2) {
            New-Item -Path $ErrorPath -Name "temp.txt" -ItemType "file"
            $content3 = Get-Content -Path "$Content2" -Raw | ForEach-Object -Process { $_ -replace "- `r`n", '- ' } 
            Add-Content -Path "$ErrorPath\temp.txt" -Value $content3
            $content4 = Get-ChildItem -path "$ErrorPath\temp.txt" -Recurse | Select-String -Pattern "error" -AllMatches | ForEach-Object { $_.Line }
            if ($content4.length -eq 0) { 
                Write-Host "empty"
            } 
            else {
                Add-Content -path $ErrorFile -Value $Content2
            }	
            add-Content $ErrorFile -value $content4, "`n"
            Remove-Item "$ErrorPath\temp.txt"	
        }
    }
    else { Write-Host "Files are not existed" }

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

    $content1 = Get-ChildItem -Include ServiceLog*.* -Path $LogPath -Recurse  | Sort-Object name -desc | Select-Object -expand Fullname
    foreach ($Content1 in $content1) {
        New-Item -Path $ErrorPath -Name "temp.txt" -ItemType "file"
        $content2 = Get-Content -Path "$Content1" -Raw | ForEach-Object -Process { $_ -replace "- `r`n", '- ' }
        Add-Content -Path "$ErrorPath\temp.txt" -Value $content2
        $content3 = Get-ChildItem -path "$ErrorPath\temp.txt" -Recurse | Select-String -Pattern "$date" -AllMatches | Foreach { $_.Line }
        if ($content3.length -eq 0) { 
            Write-Host "empty"
        } 
        else {
            Add-Content $ErrorFile -Value $Content1
        }	
        Add-Content $ErrorFile -value $content3, "`n"
        Remove-Item "$ErrorPath\temp.txt"
    }

    $content2 = Get-ChildItem -Include pr_log*.* -Path $LogPath -Recurse | Sort-Object name -desc | Select-Object -expand Fullname
    foreach ($Content2 in $content2) {
        New-Item -Path $ErrorPath -Name "temp.txt" -ItemType "file"
        $content7 = Get-Content -Path "$Content2" -Raw | ForEach-Object -Process { $_ -replace "- `r`n", '- ' }
        Add-Content -Path "$ErrorPath\temp.txt" -Value $content7
        $content8 = Get-ChildItem -path "$ErrorPath\temp.txt" -Recurse | Select-String -Pattern "$date" -AllMatches | Foreach { $_.Line }
        if ($content8.length -eq 0) { 
            Write-Host "empty"
        } 
        else {
            Add-Content $ErrorFile -Value $Content2
        }
        add-Content $ErrorFile -value $content8, "`n"
        Remove-Item "$ErrorPath\temp.txt"
    }

    $content3 = Get-ChildItem -Include InteractionLog*.* -Path $LogPath -Recurse | Sort-Object name -desc | Select-Object -expand Fullname
    foreach ($Content3 in $content3) {
        New-Item -Path $ErrorPath -Name "temp.txt" -ItemType "file"
        $content10 = Get-Content -LiteralPath "$Content3" -Raw | ForEach-Object -Process { $_ -replace "- `r`n", '- ' }
        Add-Content -Path "$ErrorPath\temp.txt" -Value $content10
        $content11 = Get-ChildItem -path "$ErrorPath\temp.txt" -Recurse | Select-String -Pattern "$date" -AllMatches | ForEach-Object { $_.Line }    
        if ($content11.length -eq 0) { 
            Write-Host "empty"
        } 
        else {
            Add-Content -path $ErrorFile -Value $Content3
        }	
        Add-Content $ErrorFile -value $content11, "`n"
        Remove-Item "$ErrorPath\temp.txt"
    }

    $content4 = Get-ChildItem -Include ServerLog*.* -Path $LogPath -Recurse | Sort-Object name -desc | Select-Object -expand Fullname
    foreach ($Content4 in $content4) {
        New-Item -Path $ErrorPath -Name "temp.txt" -ItemType "file"
        $content13 = Get-Content -LiteralPath "$Content4" -Raw | ForEach-Object -Process { $_ -replace "- `r`n", '- ' }
        Add-Content -Path "$ErrorPath\temp.txt" -Value $content13
        $content14 = Get-ChildItem -path "$ErrorPath\temp.txt" -Recurse | Select-String -Pattern "$date" -AllMatches | ForEach-Object { $_.Line } 
        if ($content14.length -eq 0) { 
            Write-Host "empty"
        } 
        else {
            Add-Content -path $ErrorFile -Value $Content4
        }	
        Add-Content $ErrorFile -value $content14, "`n"
        Remove-Item "$ErrorPath\temp.txt"
    }

    $content5 = Get-ChildItem -Include ConfigurationLog*.* -Path $LogPath -Recurse | Sort-Object name -desc | Select-Object -expand Fullname
    foreach ($Content5 in $content5) {
        New-Item -Path $ErrorPath -Name "temp.txt" -ItemType "file"
        $content15 = Get-Content -LiteralPath "$Content5" -Raw | ForEach-Object -Process { $_ -replace "- `r`n", '- ' }
        Add-Content -Path "$ErrorPath\temp.txt" -Value $content15
        $content13 = Get-ChildItem -path "$ErrorPath\temp.txt" -Recurse | Select-String -Pattern "$date" -AllMatches | ForEach-Object { $_.Line } 
        if ($content13.length -eq 0) { 
            Write-Host "empty"
        } 
        else {
            Add-Content -path $ErrorFile -Value $Content5
        }	
        Add-Content $ErrorFile -value $content13, "`n"
        Remove-Item "$ErrorPath\temp.txt"
    }

    $content6 = Get-ChildItem -Include Tray*.* -Path $LogPath -Recurse | Sort-Object name -desc | Select-Object -expand Fullname
    foreach ($Content6 in $content6) {
        New-Item -Path $ErrorPath -Name "temp.txt" -ItemType "file"
        $content15 = Get-Content -LiteralPath "$Content6" -Raw | ForEach-Object -Process { $_ -replace "- `r`n", '- ' }
        Add-Content -Path "$ErrorPath\temp.txt" -Value $content15
        $content13 = Get-ChildItem -path "$ErrorPath\temp.txt" -Recurse | Select-String -Pattern "$date" -AllMatches | ForEach-Object { $_.Line } 
        if ($content13.length -eq 0) { 
            Write-Host "empty"
        } 
        else {
            Add-Content -path $ErrorFile -Value $Content6
        }	
        Add-Content $ErrorFile -value $content13, "`n"
        Remove-Item "$ErrorPath\temp.txt"
    }

    if (Test-path $EALogs1) {
        $content6 = Get-ChildItem -Path $EALogs1 -Recurse | Sort-Object name -desc | Select-Object -expand Fullname
    } 
    elseif (Test-path $EALogs2) {
        $content6 = Get-ChildItem -Path $EALogs2 -Recurse | Sort-Object name -desc | Select-Object -expand Fullname
    }
    foreach ($Content6 in $content6) {
        New-Item -Path $ErrorPath -Name "temp.txt" -ItemType "file"
        $content2 = Get-Content -Path "$Content6" -Raw | ForEach-Object -Process { $_ -replace "- `r`n", '- ' }
        Add-Content -Path "$ErrorPath\temp.txt" -Value $content2
        $content3 = Get-ChildItem -path "$ErrorPath\temp.txt" -Recurse | Select-String -Pattern "$date" -AllMatches | ForEach-Object { $_.Line }
        if ($content3.length -eq 0) {
            Write-Host "empty"
        } 
        else {
            Add-Content -path $ErrorFile -Value $Content6
        }	
        Add-Content -path $ErrorFile -Value $content3, "`n"
        Remove-Item "$ErrorPath\temp.txt"
    }


    if (Test-path $InstallerLogs) { 
        $content7 = Get-ChildItem -Path $InstallerLogs -Recurse -File | Sort-Object name -desc | Select-Object -expand Fullname
        foreach ($Content7 in $content7) {
            New-Item -Path $ErrorPath -Name "temp.txt" -ItemType "file"
            $content3 = Get-Content -Path "$Content7" -Raw | ForEach-Object -Process { $_ -replace "- `r`n", '- ' } 
            Add-Content -Path "$ErrorPath\temp.txt" -Value $content3
            $content4 = Get-ChildItem -path "$ErrorPath\temp.txt" -Recurse | Select-String -Pattern "$date" -AllMatches | ForEach-Object { $_.Line }
            if ($content4.length -eq 0) { 
                Write-Host "empty"
            } 
            else {
                Add-Content -path $file -Value $Content7
            }	
            add-Content $ErrorFile -value $content4, "`n"
            Remove-Item "$ErrorPath\temp.txt"	
        }
    }
    else { Write-Host "Files are not existed" }


    $content8 = Get-ChildItem -Include ComputerControl*.* -Path $LogPath -Recurse | Sort-Object name -desc | Select-Object -expand Fullname
    foreach ($Content8 in $content8) {
        New-Item -Path $ErrorPath -Name "temp.txt" -ItemType "file"
        $content2 = Get-Content -Path "$Content8" -Raw | ForEach-Object -Process { $_ -replace "- `r`n", '- ' }
        Add-Content -Path "$ErrorPath\temp.txt" -Value $content2
        $content3 = Get-ChildItem -path "$ErrorPath\temp.txt" -Recurse | Select-String -Pattern "$date" -AllMatches | ForEach-Object { $_.Line }
        if ($content3.length -eq 0) {
            Write-Host "empty"
        } 
        else {
            Add-Content -path $ErrorFile -Value $Content8
        }	
        Add-Content -path $ErrorFile -Value $content3, "`n"
        Remove-Item "$ErrorPath\temp.txt"
    }

    #(gc "$ErrorPath\$date.txt") | ? {$_.trim() -ne ""} | Set-Content "$ErrorPath\date.txt"

}