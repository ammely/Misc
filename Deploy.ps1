# deploy.ps1
param (
    [string]$Param1,
    [string]$Param2,
    [string]$Param3,
    [string]$Param4
)

Function First {
    # Function code here
    param (
        [string]$Param1
    )
    $availableUSBs = (@(Get-Volume | Where-Object DriveType -eq Removable | Where-Object FileSystemType -eq NTFS |  Select-Object FileSystemLabel).FileSystemLabel ) -replace ".$"
    Write-Host ("Available USB drives: $availableUSBs`r`n")
    Write-Host ("Available USB drives: $Param1`r`n")
    $Param1 = $Param1 -replace "'", ""
    #$matchDeploy = (Compare-Object -DifferenceObject $Param1 -ReferenceObject $availableUSBs -CaseSensitive -ExcludeDifferent -IncludeEqual | Select-Object InputObject).InputObject
    $Param1
    $matchDeploy = $availableUSBs | Where-Object { $_ -eq $Param1 }

    Write-Host ("`r`nSelecting: $matchDeploy`r`n")

    if ($matchDeploy.count -gt 0) {
    
        Write-Host ("`r`nSelecting: $matchDeploy`r`n")

        $DeployName = "$matchDeploy" + "D"
        $BootName = "$matchDeploy" + "B"
        Write-Host ("Setting deploy name to $DeployName and $BootName`r`n")

        $paths = @("$env:USERPROFILE\Downloads")#, "D:\")
        $CheckDownloadedDeploy = (Get-ChildItem -Path $paths | Where-Object { $_.Name -match "$matchDeploy" -and $_.Name -match ".7z" }) -replace ".7z", ""

        $CheckDownloadedDeployFullName = (Get-ChildItem -Path $paths | Where-Object { $_.Name -match "$matchDeploy" -and $_.Name -match ".7z" }).FullName -replace ".7z", ""
        Write-Host ("Found deploy: $CheckDownloadedDeploy`r`n")
        if ($CheckDownloadedDeploy.count -gt 0) {

            Set-Location  "C:\Program Files\7-Zip"

            # clear content in USB
            Write-Host ("Formatting both $DeployName and $BootName`r`n")
            $Test1 = Format-Volume -FriendlyName $DeployName -FileSystem NTFS -NewFileSystemLabel $DeployName
            $Test2 = Format-Volume -FriendlyName $BootName -FileSystem FAT32 -NewFileSystemLabel $BootName

            # Find and select driver for USB
            $getDepLetter = (Get-Volume | Where-Object { ($_.FileSystemLabel -eq "$DeployName") }).DriveLetter
            $getBootLetter = (Get-Volume | Where-Object { ($_.FileSystemLabel -eq "$BootName") }).DriveLetter
            Write-Host ("Found following driver letters: $getDepLetter & $getBootLetter`r`n")
                
            # Select correct deploy from Download
            Write-Host ("Unpacking...`r`n")
            $unpack = .\7z.exe x "$CheckDownloadedDeployFullName.7z" -o"$getDepLetter":\  -p5rd4c5vgcTvuKC -r
    
            # Move files to its proper path

    
            Write-Host "name1: ${getDepLetter}:\$CheckDownloadedDeploy\deploy"
    
            Write-Host ("Moving folders to its right path and cleaning..`r`n")
            Get-ChildItem -Path "${getDepLetter}:\$CheckDownloadedDeploy\deploy" -Recurse | Move-Item -Destination "${getDepLetter}:"
            Get-ChildItem -Path "${getDepLetter}:\$CheckDownloadedDeploy\winpe" -Recurse | Move-Item -Destination "${getBootLetter}:"


            Write-Host "remove ${getDepLetter}:\$CheckDownloadedDeploy"
            Remove-Item -Path "${getDepLetter}:\$CheckDownloadedDeploy" -Force -Recurse
        }
    }
    Write-Host ("DONE`r`n")

}

Function Second {
    # Function code here
    param (
        [string]$Param2
    )
    $availableUSBs = (@(Get-Volume | Where-Object DriveType -eq Removable | Where-Object FileSystemType -eq NTFS |  Select-Object FileSystemLabel).FileSystemLabel ) -replace ".$"
    Write-Host ("Available USB drives: $availableUSBs`r`n")
    $Param2 = $Param2 -replace "'", ""
    #$matchDeploy = (Compare-Object -DifferenceObject $Param1 -ReferenceObject $availableUSBs -CaseSensitive -ExcludeDifferent -IncludeEqual | Select-Object InputObject).InputObject
    Write-Host ("Param: $Param2`r`n")
    
    if ($availableUSBs -eq "I-110-8W10" -and $Param2 -eq "I-110-850_W10" ) {
        $Param2 = "I-110-8W10" 
        Write-Host "Here"
    }
    elseif ($availableUSBs -eq "I-110-8W11" ) {
        $Param2 = "I-110-8W11" 
    }
    
    $matchDeploy = $availableUSBs | Where-Object { $_ -eq $Param2 }
    
    Write-Host ("`r`matchDeploy1: $matchDeploy`r`n")

    if ($matchDeploy.count -gt 0) {
    
        Write-Host ("`r`matchDeploy: $matchDeploy`r`n")

        $DeployName = "$matchDeploy" + "D"
        $BootName = "$matchDeploy" + "B"
        Write-Host ("Setting deploy name to $DeployName and $BootName`r`n")

        $paths = @("$env:USERPROFILE\Downloads")#, "D:\")
        if ($matchDeploy -eq "I-110" -and $matchDeploy -notmatch '850') {
            $CheckDownloadedDeploy = (Get-ChildItem -Path $paths | Where-Object { $_.Name -match "$matchDeploy" -and $_.Name -match ".7z" -and $_.Name -notmatch '850' }) -replace ".7z", ""
            $CheckDownloadedDeployFullName = (Get-ChildItem -Path $paths | Where-Object { $_.Name -match "$matchDeploy" -and $_.Name -match ".7z" -and $_.Name -notmatch '850' }).FullName -replace ".7z", ""
        }
        elseif ($matchDeploy -eq "I-110-8W10") {
            $CheckDownloadedDeploy = (Get-ChildItem -Path $paths | Where-Object { $_.Name -match "I-110-850_W10" -and $_.Name -match ".7z" }) -replace ".7z", ""
            $CheckDownloadedDeployFullName = (Get-ChildItem -Path $paths | Where-Object { $_.Name -match "I-110-850_W10" -and $_.Name -match ".7z" }).FullName -replace ".7z", ""
        }
        elseif ($matchDeploy -eq "I-110-8W11") {
            $CheckDownloadedDeploy = (Get-ChildItem -Path $paths | Where-Object { $_.Name -match "I-110-850_W11" -and $_.Name -match ".7z" }) -replace ".7z", ""
            $CheckDownloadedDeployFullName = (Get-ChildItem -Path $paths | Where-Object { $_.Name -match "I-110-850_W11" -and $_.Name -match ".7z" }).FullName -replace ".7z", ""
        }
        Write-Host ("Found deploy: $CheckDownloadedDeploy`r`n")
        if ($CheckDownloadedDeploy.count -gt 0) {

            Set-Location  "C:\Program Files\7-Zip"

            # clear content in USB
            Write-Host ("Formatting both $DeployName and $BootName`r`n")
            $Test1 = Format-Volume -FriendlyName $DeployName -FileSystem NTFS -NewFileSystemLabel $DeployName
            $Test2 = Format-Volume -FriendlyName $BootName -FileSystem FAT32 -NewFileSystemLabel $BootName

            # Find and select driver for USB
            $getDepLetter = (Get-Volume | Where-Object { ($_.FileSystemLabel -eq "$DeployName") }).DriveLetter
            $getBootLetter = (Get-Volume | Where-Object { ($_.FileSystemLabel -eq "$BootName") }).DriveLetter
            Write-Host ("Found following driver letters: $getDepLetter & $getBootLetter`r`n")
                
            # Select correct deploy from Download
            Write-Host ("Unpacking...`r`n")
            $unpack = .\7z.exe x "$CheckDownloadedDeployFullName.7z" -o"$getDepLetter":\  -p5rd4c5vgcTvuKC -r
    
            # Move files to its proper path

    
            Write-Host "name1: ${getDepLetter}:\$CheckDownloadedDeploy\deploy"
    
            Write-Host ("Moving folders to its right path and cleaning..`r`n")
            Get-ChildItem -Path "${getDepLetter}:\$CheckDownloadedDeploy\deploy" -Recurse | Move-Item -Destination "${getDepLetter}:"
            Get-ChildItem -Path "${getDepLetter}:\$CheckDownloadedDeploy\winpe" -Recurse | Move-Item -Destination "${getBootLetter}:"


            Write-Host "remove ${getDepLetter}:\$CheckDownloadedDeploy"
            Remove-Item -Path "${getDepLetter}:\$CheckDownloadedDeploy" -Force -Recurse
        }
    }
    Write-Host ("DONE`r`n")
}

Function Third {
    # Function code here
    param (
        [string]$Param3
    )
    $availableUSBs = (@(Get-Volume | Where-Object DriveType -eq Removable | Where-Object FileSystemType -eq NTFS |  Select-Object FileSystemLabel).FileSystemLabel ) -replace ".$"
    
    Write-Host ("Available USB drives: $availableUSBs`r`n")
    $Param3 = $Param3 -replace "'", ""
    Write-Host ("Param: $Param3`r`n")
    

    $matchDeploy = $availableUSBs | Where-Object { $_ -eq $Param3 }
    
    Write-Host ("`r`matchDeploy1: $matchDeploy`r`n")

    if ($matchDeploy.count -gt 0) {
    
        Write-Host ("`r`matchDeploy: $matchDeploy`r`n")

        $DeployName = "$matchDeploy" + "D"
        if ($matchDeploy -eq "ISeries_IOT" ) { 
            $BootName = "ISeries_IOT" 
            Write-Host "boot1"
        }
        elseif ($matchDeploy -eq "I-Series+" ) { 
            $BootName = "I-SeriesB"
            Write-Host "boot2" 
        }
        else { 
            $BootName = "$matchDeploy" + "B"
            Write-Host "boot3" 
        }

        Write-Host ("Setting deploy name to $DeployName and $BootName`r`n")

        $paths = @("$env:USERPROFILE\Downloads")#, "D:\")
        if ($matchDeploy -eq "ISeries") {
            $CheckDownloadedDeploy = (Get-ChildItem -Path $paths | Where-Object { $_.Name -match "ISeries" -and $_.Name -match ".7z" -and $_.Name -notmatch 'IOT' }) -replace ".7z", ""
            $CheckDownloadedDeployFullName = (Get-ChildItem -Path $paths | Where-Object { $_.Name -match "ISeries" -and $_.Name -match ".7z" -and $_.Name -notmatch 'IOT' }).FullName -replace ".7z", ""
            Write-Host "inside1"
            Write-Host "inside1 $CheckDownloadedDeploy"
            Write-Host "inside1 $CheckDownloadedDeployFullName"

        }
        else {
            $CheckDownloadedDeploy = (Get-ChildItem -Path $paths | Where-Object { $_.Name -match "$matchDeploy" -and $_.Name -match ".7z" -and $_.Name -notmatch '850' }) -replace ".7z", ""
            $CheckDownloadedDeployFullName = (Get-ChildItem -Path $paths | Where-Object { $_.Name -match "$matchDeploy" -and $_.Name -match ".7z" -and $_.Name -notmatch '850' }).FullName -replace ".7z", ""
            Write-Host "inside"
        }
        Write-Host ("Found deploy: $CheckDownloadedDeploy`r`n")
        if ($CheckDownloadedDeploy.count -gt 0) {

            Set-Location  "C:\Program Files\7-Zip"

            # clear content in USB
            Write-Host ("Formatting both $DeployName and $BootName`r`n")
            $Test1 = Format-Volume -FriendlyName $DeployName -FileSystem NTFS -NewFileSystemLabel $DeployName
            $Test2 = Format-Volume -FriendlyName $BootName -FileSystem FAT32 -NewFileSystemLabel $BootName

            # Find and select driver for USB
            $getDepLetter = (Get-Volume | Where-Object { ($_.FileSystemLabel -eq "$DeployName") }).DriveLetter
            $getBootLetter = (Get-Volume | Where-Object { ($_.FileSystemLabel -eq "$BootName") }).DriveLetter
            Write-Host ("Found following driver letters: $getDepLetter & $getBootLetter`r`n")
                
            # Select correct deploy from Download
            Write-Host ("Unpacking...`r`n")
            $unpack = .\7z.exe x "$CheckDownloadedDeployFullName.7z" -o"$getDepLetter":\  -p5rd4c5vgcTvuKC -r
    
            # Move files to its proper path

    
            Write-Host "name1: ${getDepLetter}:\$CheckDownloadedDeploy\deploy"
    
            Write-Host ("Moving folders to its right path and cleaning..`r`n")
            Get-ChildItem -Path "${getDepLetter}:\$CheckDownloadedDeploy\deploy" -Recurse | Move-Item -Destination "${getDepLetter}:"
            Get-ChildItem -Path "${getDepLetter}:\$CheckDownloadedDeploy\winpe" -Recurse | Move-Item -Destination "${getBootLetter}:"


            Write-Host "remove ${getDepLetter}:\$CheckDownloadedDeploy"
            Remove-Item -Path "${getDepLetter}:\$CheckDownloadedDeploy" -Force -Recurse
        }
    }
    Write-Host ("DONE`r`n")
}

Function Four {
    # Function code here
    param (
        [string]$Param4
    )
    $availableUSBs = (@(Get-Volume | Where-Object DriveType -eq Removable | Where-Object FileSystemType -eq NTFS |  Select-Object FileSystemLabel).FileSystemLabel ) -replace ".$"
    
    Write-Host ("Available USB drives44444: $availableUSBs`r`n")
    $Param4 = $Param4 -replace "'", ""
    Write-Host ("Param: $Param4`r`n")
    
    if ($availableUSBs -eq "Surface_SP7" -and $Param4 -eq "Surface_Pro_SP7" ) {
        $Param4 = "Surface_SP7" 
        Write-Host "Here"
    }
    elseif ($availableUSBs -eq "Surface_SP6" ) {
        $Param4 = "Surface_SP6" 
    }
    
    $matchDeploy = $availableUSBs | Where-Object { $_ -eq $Param4 }
    
    Write-Host ("`r`matchDeploy1: $matchDeploy`r`n")

    if ($matchDeploy.count -gt 0) {
    
        Write-Host ("`r`matchDeploy: $matchDeploy`r`n")

        $DeployName = "$matchDeploy" + "D"
        if ($matchDeploy -eq "Surface_SP7" ) { 
            $BootName = "Surface_SP7"
            Write-Host "boot33" 
        }
        elseif ($matchDeploy -eq "Surface_SP6" ) { 
            $BootName = "Surface_SP6"
            Write-Host "boot66" 
        }
        else { 
            $BootName = "$matchDeploy" + "B"
            Write-Host "boot3" 
        }

        Write-Host ("Setting deploy name to $DeployName and $BootName`r`n")

        $paths = @("$env:USERPROFILE\Downloads")#, "D:\")
        if ($matchDeploy -eq "Surface_SP7") {
            $CheckDownloadedDeploy = (Get-ChildItem -Path $paths | Where-Object { $_.Name -match "Surface_Pro_SP7" -and $_.Name -match ".7z" }) -replace ".7z", ""
            $CheckDownloadedDeployFullName = (Get-ChildItem -Path $paths | Where-Object { $_.Name -match "Surface_Pro_SP7" -and $_.Name -match ".7z" -and $_.Name -notmatch 'IOT' }).FullName -replace ".7z", ""
            Write-Host "inside331"
            Write-Host "inside1333 $CheckDownloadedDeploy"
            Write-Host "inside1333 $CheckDownloadedDeployFullName"

        }
        elseif ($matchDeploy -eq "Surface_SP6") {
            $CheckDownloadedDeploy = (Get-ChildItem -Path $paths | Where-Object { $_.Name -match "Surface_Pro_SP6" -and $_.Name -match ".7z" }) -replace ".7z", ""
            $CheckDownloadedDeployFullName = (Get-ChildItem -Path $paths | Where-Object { $_.Name -match "Surface_Pro_SP6" -and $_.Name -match ".7z" -and $_.Name -notmatch 'IOT' }).FullName -replace ".7z", ""
            Write-Host "inside33ssdsfdf1"
            Write-Host "inside13dfdf33 $CheckDownloadedDeploy"
            Write-Host "inside13fdfdgg $CheckDownloadedDeployFullName"

        }
        else {
            $CheckDownloadedDeploy = (Get-ChildItem -Path $paths | Where-Object { $_.Name -match "$matchDeploy" -and $_.Name -match ".7z" -and $_.Name -notmatch '850' }) -replace ".7z", ""
            $CheckDownloadedDeployFullName = (Get-ChildItem -Path $paths | Where-Object { $_.Name -match "$matchDeploy" -and $_.Name -match ".7z" -and $_.Name -notmatch '850' }).FullName -replace ".7z", ""
            Write-Host "inside"
        }
        Write-Host ("Found deploy: $CheckDownloadedDeploy`r`n")
        if ($CheckDownloadedDeploy.count -gt 0) {

            Set-Location  "C:\Program Files\7-Zip"

            # clear content in USB
            Write-Host ("Formatting both $DeployName and $BootName`r`n")
            $Test1 = Format-Volume -FriendlyName $DeployName -FileSystem NTFS -NewFileSystemLabel $DeployName
            $Test2 = Format-Volume -FriendlyName $BootName -FileSystem FAT32 -NewFileSystemLabel $BootName

            # Find and select driver for USB
            $getDepLetter = (Get-Volume | Where-Object { ($_.FileSystemLabel -eq "$DeployName") }).DriveLetter
            $getBootLetter = (Get-Volume | Where-Object { ($_.FileSystemLabel -eq "$BootName") }).DriveLetter
            Write-Host ("Found following driver letters: $getDepLetter & $getBootLetter`r`n")
                
            # Select correct deploy from Download
            Write-Host ("Unpacking...`r`n")
            $unpack = .\7z.exe x "$CheckDownloadedDeployFullName.7z" -o"$getDepLetter":\  -p5rd4c5vgcTvuKC -r
    
            # Move files to its proper path

    
            Write-Host "name1: ${getDepLetter}:\$CheckDownloadedDeploy\deploy"
    
            Write-Host ("Moving folders to its right path and cleaning..`r`n")
            Get-ChildItem -Path "${getDepLetter}:\$CheckDownloadedDeploy\deploy" -Recurse | Move-Item -Destination "${getDepLetter}:"
            Get-ChildItem -Path "${getDepLetter}:\$CheckDownloadedDeploy\winpe" -Recurse | Move-Item -Destination "${getBootLetter}:"


            Write-Host "remove ${getDepLetter}:\$CheckDownloadedDeploy"
            Remove-Item -Path "${getDepLetter}:\$CheckDownloadedDeploy" -Force -Recurse
        }
    }
    Write-Host ("DONE`r`n")
}



# Call the First function with the provided argument
if ($Param1) {
    First -Param1 $Param1
}

# Call the Second function with the provided argument
if ($Param2) {
    Second -Param2 $Param2
}

# Call the Second function with the provided argument
if ($Param3) {
    Third -Param3 $Param3
}
# Call the Second function with the provided argument
if ($Param4) {
    Four -Param4 $Param4
}
