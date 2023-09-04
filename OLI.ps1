$PSScriptRoot
$installerName = Read-Host -Prompt 'ENTER the name of OLI'
    
$fpath = Get-ChildItem -Path $PSScriptRoot -Filter "$fileversion" -Recurse -erroraction SilentlyContinue | Select-Object -expand Fullname | Split-Path
$regPath = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\"

for ($i = 1; $i -le 5; $i++) {
    $tobiiVer = Get-ChildItem -Path $regPath | Get-ItemProperty | Where-Object { $_.Displayname -Match "Tobii Experience Software For Windows" } | Select-Object UninstallString

    if ($tobiiVer) {
        # Uninstall the software
        Read-Host "Press ENTER to uninstall Tobii Experience Software"
        $uninstallString = $tobiiVer.UninstallString -replace "msiexec.exe", "" -replace "/I", ""
        $uninstallProcess = Start-Process "msiexec.exe" -ArgumentList "/X $uninstallString /quiet /norestart" -Wait -PassThru

        if ($uninstallProcess.ExitCode -ne 0) {
            Write-Error "Error $uninstallProcess.ExitCode: Failed to uninstall Tobii Experience Software."
            break
        }
    }

    # Install the offline installer
    Write-Host "path $fpath\$installerName"
    Read-Host "Press ENTER to install Tobii Experience Software"
    try {
        Start-Process "$fpath\$installerName" -ArgumentList "/quiet" -Wait

    }
    catch {
        Write-Error "Error: Failed to install Tobii Experience Software."
        break
    }

    # Output the iteration number to indicate progress
    Write-Output "Iteration: $i"
}

