#_V0.3
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
    
    $ErrorPath = "$LogPath\ErrorLogs"

    if (!(Test-Path "$LogPath\ErrorLogs")) {
        $add = New-Item -Path "$ErrorPath" -ItemType Directory
    }

    if (!(Test-Path "$LogPath\ErrorLogs\LatestErrors.txt")) {
        $ErrorFile = New-Item -Path $ErrorPath -Name "LatestErrors.txt" -ItemType "file"
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
            add-Content $ErrorFile -Value $file
            New-Item -Path $ErrorPath -Name "temp.txt" -ItemType "file"
            $content3 = Get-Content -Path "$file" -Raw | ForEach-Object -Process { $_ -replace "- `r`n", '- ' }
            Add-Content -Path "$LogPath\ErrorLogs\temp.txt" -Value $content3
            $content = Get-ChildItem -path "$LogPath\ErrorLogs\temp.txt" -Recurse | Select-String -Pattern "error" -AllMatches | Foreach { $_.Line }
            add-Content $ErrorFile -value $content, "`n"
            Remove-Item "$LogPath\ErrorLogs\temp.txt"
        }
    }
}

Function AllEALogs {
    $LogPath = $x
    if ($LogPath -match "SysInfo") {
        $EALogs = "$LogPath\TOBII_DYNAVOX_APPDATA\EYEASSIST\LOGS"
    }
    else {
        $EALogs = "$LogPath\Logs\Eye Assist\Logs"
    }
    $ErrorPath = "$LogPath\ErrorLogs"
    if (!(Test-Path "$LogPath\ErrorLogs")) {
        $add = New-Item -Path "$ErrorPath" -ItemType Directory
        Write-Host "Folder already exist1"
    } 
    if (!(Test-Path "$LogPath\ErrorLogs\EALogs.txt")) {
        $ErrorFile = New-Item -Path $ErrorPath -Name "EALogs.txt" -ItemType "file"
        Write-Host "creating file"
    } 
    else {
        Clear-Content -Path "$ErrorPath\EALogs.txt"
        Write-Host "cleaing"
    }
    $content1 = Get-ChildItem -Path $EALogs -Recurse | Sort name -desc
    $content1 = $content1.Name

    foreach ($Content1 in $content1) {
        add-Content $ErrorFile -Value $EALogs\$Content1
        New-Item -Path $ErrorPath -Name "temp.txt" -ItemType "file"
        $content2 = Get-Content -Path "$EALogs\$Content1" -Raw | ForEach-Object -Process { $_ -replace "- `r`n", '- ' }
        Add-Content -Path "$LogPath\ErrorLogs\temp.txt" -Value $content2
        $content3 = Get-ChildItem -path "$LogPath\ErrorLogs\temp.txt" -Recurse | Select-String -Pattern "error" -AllMatches | Foreach { $_.Line }
        add-Content $ErrorFile -value $content3, "`n"
        Remove-Item "$LogPath\ErrorLogs\temp.txt"
    }
}

Function AllTTechLogs {
    $LogPath = $x
    if ($LogPath -match "SysInfo") {
        $InteractionFolder = "$LogPath\TOBII_PROGRAMDATA\Tobii%20Interaction"
    }
    else {
        $InteractionFolder = "$LogPath\Logs\Tobii Interaction\ProgramData"
    }
    $ErrorPath = "$LogPath\ErrorLogs"
    if (!(Test-Path "$LogPath\ErrorLogs")) {
        $add = New-Item -Path "$ErrorPath" -ItemType Directory
        Write-Host "Folder already exist2"
    }
    if (!(Test-Path "$LogPath\ErrorLogs\ServiceLog.txt")) {
        $ErrorFile = New-Item -Path $ErrorPath -Name "ServiceLog.txt" -ItemType "file"
        Write-Host "creating file"
    } 
    else {
        Clear-Content -Path "$ErrorPath\ServiceLog.txt"
        Write-Host "cleaing"
    }

    $content = Get-ChildItem -Include ServiceLog.* -Path $InteractionFolder -Recurse | Sort name -desc
    $content2 = $content.Name

    foreach ($Content2 in $content2) {
        add-Content $ErrorFile -Value $Content2
        New-Item -Path $ErrorPath -Name "temp.txt" -ItemType "file"
        $content3 = Get-Content -Path "$InteractionFolder\$Content2" -Raw | ForEach-Object -Process { $_ -replace "- `r`n", '- ' }
        Add-Content -Path "$LogPath\ErrorLogs\temp.txt" -Value $content3
        $content4 = Get-ChildItem -path "$LogPath\ErrorLogs\temp.txt" -Recurse | Select-String -Pattern "error" -AllMatches | Foreach { $_.Line }
        add-Content $ErrorFile -value $content4, "`n"
        Remove-Item "$LogPath\ErrorLogs\temp.txt"
    }
    if ($LogPath -match "SysInfo") {
        $PRLogs = "$LogPath\TOBII_PROGRAMDATA\Tobii%20Platform%20Runtime\IS5GIBBONGAZE"
    }
    else {
        $PRLogs = "$LogPath\Logs\Tobii Platform Runtime\IS5GIBBONGAZE"
    }
    $content5 = gci $PRLogs -file | Sort name -desc
    $content6 = $content5.Name
    if (!(Test-Path "$LogPath\ErrorLogs\PR_logs.txt")) {
        $ErrorFile = New-Item -Path $ErrorPath -Name "PR_logs.txt" -ItemType "file"
        Write-Host "creating file"
    } 
    else {
        Clear-Content -Path "$ErrorPath\PR_logs.txt"
        Write-Host "cleaing"
    }
    foreach ($Content6 in $content6) {
        Add-Content $ErrorFile -Value $Content6
        New-Item -Path $ErrorPath -Name "temp.txt" -ItemType "file"
        $content7 = Get-Content -Path "$PRLogs\$Content6" -Raw
        Add-Content -Path "$LogPath\ErrorLogs\temp.txt" -Value $content7
        $content8 = Get-ChildItem -path "$LogPath\ErrorLogs\temp.txt" -Recurse | Select-String -Pattern "error" -AllMatches | Foreach { $_.Line }
        add-Content $ErrorFile -value $content8, "`n"
        Remove-Item "$LogPath\ErrorLogs\temp.txt"
    }

    if ($LogPath -match "SysInfo") {
        $InteractionFolder2 = "$LogPath\TOBII_LOCALAPPDATA\Tobii%20Interaction"
    }
    else {
        $InteractionFolder2 = "$LogPath\Logs\Tobii Interaction\LocalAppData"
    }
    $content9 = Get-ChildItem -Include InteractionLog.* -Path $InteractionFolder2 -Recurse | Sort name -desc
    $content9 = $content9.Name
    if (!(Test-Path "$LogPath\ErrorLogs\InteractionLog.txt")) {
        $ErrorFile = New-Item -Path $ErrorPath -Name "InteractionLog.txt" -ItemType "file"
        Write-Host "creating file"
    } 
    else {
        Clear-Content -Path "$ErrorPath\InteractionLog.txt"
        Write-Host "cleaing"
    }
    foreach ($Content9 in $content9) {
        Add-Content $ErrorFile -Value $Content9
        New-Item -Path $ErrorPath -Name "temp.txt" -ItemType "file"
        $content10 = Get-Content -Path "$InteractionFolder2\$Content9" -Raw | ForEach-Object -Process { $_ -replace "- `r`n", '- ' }
        Add-Content -Path "$LogPath\ErrorLogs\temp.txt" -Value $content10
        $content11 = Get-ChildItem -path "$LogPath\ErrorLogs\temp.txt" -Recurse | Select-String -Pattern "error" -AllMatches | Foreach { $_.Line }
        add-Content $ErrorFile -value $content11, "`n"
        Remove-Item "$LogPath\ErrorLogs\temp.txt"
    }

    $content12 = Get-ChildItem -Include ServerLog.* -Path $InteractionFolder2 -Recurse | Sort name -desc
    $content12 = $content12.Name
    if (!(Test-Path "$LogPath\ErrorLogs\ServerLog.txt")) {
        $ErrorFile = New-Item -Path $ErrorPath -Name "ServerLog.txt" -ItemType "file"
        Write-Host "creating file"
    } 
    else {
        Clear-Content -Path "$ErrorPath\ServerLog.txt"
        Write-Host "cleaing"
    }
    foreach ($Content12 in $content12) {
        Add-Content $ErrorFile -Value $Content12
        New-Item -Path $ErrorPath -Name "temp.txt" -ItemType "file"
        $content13 = Get-Content -Path "$InteractionFolder2\$Content12" -Raw | ForEach-Object -Process { $_ -replace "- `r`n", '- ' }
        Add-Content -Path "$LogPath\ErrorLogs\temp.txt" -Value $content13
        $content14 = Get-ChildItem -path "$LogPath\ErrorLogs\temp.txt" -Recurse | Select-String -Pattern "error" -AllMatches | Foreach { $_.Line }
        add-Content $ErrorFile -value $content14, "`n"
        Remove-Item "$LogPath\ErrorLogs\temp.txt"
    }
}

Function InstallerLogs {
    $LogPath = $x
    $InstallerLogs = "$LogPath\TOBII_INSTALLER_LOGS\TEMP"
    $ErrorPath = "$LogPath\ErrorLogs"
    if (!(Test-Path "$LogPath\ErrorLogs")) {
        $add = New-Item -Path "$ErrorPath" -ItemType Directory
        Write-Host "Folder already exist3"
    }
    if (!(Test-Path "$LogPath\ErrorLogs\InstallerError.txt")) {
        $ErrorFile = New-Item -Path $ErrorPath -Name "InstallerError.txt" -ItemType "file"
        Write-Host "creating file"
    } 
    else {
        Clear-Content -Path "$ErrorPath\InstallerError.txt"
        Write-Host "cleaing"
    }
    if (Test-path $InstallerLogs) { 
        $content1 = gci $InstallerLogs -file
        $content2 = $content1.Name
        foreach ($Content2 in $content2) {
            add-Content $ErrorFile -Value $Content2
            New-Item -Path $ErrorPath -Name "temp.txt" -ItemType "file"
            $content3 = Get-Content -Path "$InstallerLogs\$Content2" -Raw | ForEach-Object -Process { $_ -replace "- `r`n", '- ' } 
            Add-Content -Path "$LogPath\ErrorLogs\temp.txt" -Value $content3
            $content4 = Get-ChildItem -path "$LogPath\ErrorLogs\temp.txt" -Recurse | Select-String -Pattern "error" -AllMatches | Foreach { $_.Line }
            add-Content $ErrorFile -value $content4, "`n"
            Remove-Item "$LogPath\ErrorLogs\temp.txt"	
        }
    }
    else { Write-Host "Files are not existed" }
}

Function TimeStamp {
    $LogPath = $x
    if ($LogPath -match "SysInfo") {
        $InteractionLogs = "$LogPath\TOBII_LOCALAPPDATA\Tobii%20Interaction"
        $InteractionFolder = "$LogPath\TOBII_PROGRAMDATA\Tobii%20Interaction"
        $PRLogs = "$LogPath\TOBII_PROGRAMDATA\Tobii%20Platform%20Runtime\IS5GIBBONGAZE"
        $EALogs = "$LogPath\TOBII_DYNAVOX_APPDATA\EYEASSIST\LOGS"
    } else {
        if ($InteractionLogs -and $InteractionFolder -and $PRLogs -and $EALogs) {
            $InteractionLogs = "$LogPath\Logs\Tobii Interaction\LocalAppData"
            $InteractionFolder = "$LogPath\Logs\Tobii Interaction\ProgramData"
            $PRLogs = "$LogPath\Logs\Tobii Platform Runtime\IS5GIBBONGAZE"
            $EALogs = "$LogPath\Logs\Eye Assist\Logs"
            Write-Host "HEREEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE"
        }
        else {
            $InteractionLogs = "$LogPath\Logs\Tobii Interaction\AppData"
            $InteractionFolder = "$LogPath\Logs\Tobii Interaction\ProgramData"
            Write-Host "NOTHEREEHNONONONONNON"
        }
    }
    $InstallerLogs = "$LogPath\TOBII_INSTALLER_LOGS\TEMP"
    $ErrorPath = "$LogPath\ErrorLogs"
    if (!(Test-Path "$LogPath\ErrorLogs")) {
        $add = New-Item -Path "$ErrorPath" -ItemType Directory
        Write-Host "Folder already exist4"
    }
    $date = $x3
    if ($date -match ":") {
        $newDate = $date -replace ":" , "."
    } else {
        $newDate = $date
    }

    if (!(Test-Path "$LogPath\ErrorLogs\$newDate.txt")) {
        $ErrorFile = New-Item -Path $ErrorPath -Name "$newDate.txt" -ItemType "file"
        Write-Host "creating file"
    } 
    else {
        Clear-Content -Path "$ErrorPath\$newDate.txt"
        Write-Host "cleaing"
    }
    if (Test-path $InteractionLogs) { 
        $content1 = Get-ChildItem -Path $InteractionLogs -Recurse | Sort name -desc
        $content1 = $content1.Name
        foreach ($Content1 in $content1) {
            New-Item -Path $ErrorPath -Name "temp.txt" -ItemType "file"
            $content2 = Get-Content -Path "$InteractionLogs\$Content1" -Raw | ForEach-Object -Process { $_ -replace "- `r`n", '- ' }
            Add-Content -Path "$LogPath\ErrorLogs\temp.txt" -Value $content2
            $content3 = Get-ChildItem -path "$LogPath\ErrorLogs\temp.txt" -Recurse | Select-String -Pattern "$date" -AllMatches | Foreach { $_.Line }
            if ($content3.length -eq 0) { 
                Write-Host "empty"
            } 
            else {
                Write-Host "NOT Empty"
                add-Content $ErrorFile -Value $InteractionLogs\$Content1
            }
            add-Content $ErrorFile -value $content3, "`n"
            Remove-Item "$LogPath\ErrorLogs\temp.txt"
        }
        
    }
    else { Write-Host "Files are not existed" }
    ######################################
    if (Test-path $InteractionFolder) { 
        $content1 = Get-ChildItem -Include ServiceLog.* -Path $InteractionFolder -Recurse | Sort name -desc
        $content1 = $content1.Name
        foreach ($Content1 in $content1) {
            New-Item -Path $ErrorPath -Name "temp.txt" -ItemType "file"
            $content2 = Get-Content -Path "$InteractionFolder\$Content1" -Raw | ForEach-Object -Process { $_ -replace "- `r`n", '- ' }
            Add-Content -Path "$LogPath\ErrorLogs\temp.txt" -Value $content2
            $content3 = Get-ChildItem -path "$LogPath\ErrorLogs\temp.txt" -Recurse | Select-String -Pattern "$date" -AllMatches | Foreach { $_.Line }
            if ($content3.length -eq 0) { 
                Write-Host "empty"
            } 
            else {
                Write-Host "NOT Empty"
                add-Content $ErrorFile -Value $InteractionFolder\$Content1
            }	
            add-Content $ErrorFile -value $content3, "`n"
            Remove-Item "$LogPath\ErrorLogs\temp.txt"
        }
        
    }
    else { Write-Host "Files are not existed" }
    #####################################
    if ($PRLogs) { 
        $content5 = gci $PRLogs -file | Sort name -desc
        $content6 = $content5.Name
        foreach ($Content6 in $content6) {
            New-Item -Path $ErrorPath -Name "temp.txt" -ItemType "file"
            $content7 = Get-Content -Path "$PRLogs\$Content6" -Raw
            Add-Content -Path "$LogPath\ErrorLogs\temp.txt" -Value $content7
            $content8 = Get-ChildItem -path "$LogPath\ErrorLogs\temp.txt" -Recurse | Select-String -Pattern "$date" -AllMatches | Foreach { $_.Line }
            if ($content8.length -eq 0) { 
                Write-Host "empty"
            } 
            else {
                Write-Host "NOT Empty"
                add-Content $ErrorFile -Value $PRLogs\$Content6
            }
            add-Content $ErrorFile -value $content8, "`n"
            Remove-Item "$LogPath\ErrorLogs\temp.txt"
        }
        
    }
    else { Write-Host "Files are not existed" }
    ###########################################
    if ($EALogs) { 
        $content1 = Get-ChildItem -Path $EALogs -Recurse | Sort name -desc
        $content1 = $content1.Name
        foreach ($Content1 in $content1) {
            New-Item -Path $ErrorPath -Name "temp.txt" -ItemType "file"
            $content2 = Get-Content -Path "$EALogs\$Content1" -Raw | ForEach-Object -Process { $_ -replace "- `r`n", '- ' }
            Add-Content -Path "$LogPath\ErrorLogs\temp.txt" -Value $content2
            $content3 = Get-ChildItem -path "$LogPath\ErrorLogs\temp.txt" -Recurse | Select-String -Pattern "$date" -AllMatches | Foreach { $_.Line }
            if ($content3.length -eq 0) { 
                Write-Host "empty"
            } 
            else {
                Write-Host "NOT Empty"
                add-Content $ErrorFile -Value $EALogs\$Content1
            }
            add-Content $ErrorFile -value $content3, "`n"
            Remove-Item "$LogPath\ErrorLogs\temp.txt"
        }
        
    }
    else { Write-Host "Files are not existed" }
    ############################################
    if (Test-path $InstallerLogs) { 
        $content1 = gci $InstallerLogs -file
        $content2 = $content1.Name
        foreach ($Content2 in $content2) {
            New-Item -Path $ErrorPath -Name "temp.txt" -ItemType "file"
            $content3 = Get-Content -Path "$InstallerLogs\$Content2" -Raw | ForEach-Object -Process { $_ -replace "- `r`n", '- ' } 
            Add-Content -Path "$LogPath\ErrorLogs\temp.txt" -Value $content3
            $content4 = Get-ChildItem -path "$LogPath\ErrorLogs\temp.txt" -Recurse | Select-String -Pattern "$date" -AllMatches | Foreach { $_.Line }
            if ($content4.length -eq 0) { 
                Write-Host "empty"
            } 
            else {
                Write-Host "NOT Empty"
                add-Content $ErrorFile -Value $InstallerLogs\$Content2
            }
            add-Content $ErrorFile -value $content4, "`n"
            Remove-Item "$LogPath\ErrorLogs\temp.txt"	
        }
    }
    else { Write-Host "Files are not existed" }

    #(gc "$ErrorPath\$date.txt") | ? {$_.trim() -ne ""} | Set-Content "$ErrorPath\date.txt"
}