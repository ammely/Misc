$path = "C:\Users\aes\Desktop\tobii"
$content = gci -Path $path -Recurse | Where-Object {$_.Name -match 'Tdx.EyeTracking.RegionInteraction.EyeAssist.Sample'} | Select-Object -expand Fullname


foreach ($newcontent in $content) {



    $lines = Get-Content -path $newcontent -raw

    $lines | Select-String '\d{4}\-(0?[1-9]|1[012])\-(0?[1-9]|[12][0-9]|3[01])*\s(\d+:\d+:\d+)' -AllMatches | Foreach {$_.Matches} | Foreach {$_.Value} | Set-Content "$path\text.txt"

    #$timestamps = @([datetime]"03:37:51", [datetime]"03:37:53", [datetime]"03:37:54")

    [datetime[]] $timestamps = @(Get-Content -Path "$path\text.txt")

    if ($timestamps.Count -lt 2)
    {
        Write-Host "Only one result: " $timestamps[0]
        return
    }

    for($i = 0; $i -lt $timestamps.Count; $i++)
    {
        $previous = $timestamps[$i]
        $current = $timestamps[$i+1]
        $difference =  ($current - $previous)
        
        #($current - $previous) | Out-File "$path\text2.txt" -Append

        #Add-content $Logfile -value $logstring
        #Add-Content "$path\text2.txt" ($current - $previous)

        if (($difference) -gt ("00:00:05")) {
            Add-Content -path "$path\Results.txt" -Value $newcontent
            Add-Content "$path\Results.txt" "Gap between $current and $previous with ($difference)`n"
        } 
    }
}
Remove-Item "$path\text.txt"
#Remove-Variable * -ErrorAction SilentlyContinue