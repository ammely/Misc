$2005 = "Microsoft Visual C++ 2005 Redistributable*"
$2008 = "Microsoft Visual C++ 2008 Redistributable *"
$2010 = "Microsoft Visual C++ 2010 * Redistributable *"
$2012 = "Microsoft Visual C++ 2012 Redistributable *"
$2013 = "Microsoft Visual C++ 2013 Redistributable *"
$2015 = "Microsoft Visual C++ 2015* Redistributable *"

$path = "C:\Users\aes\Desktop\SupportTools\VC++"

$SoftList =  @("$2005", "$2008", "$2010", "$2012", "$2013", "$2015")
if (!(Test-Path "$path\VCList.txt")) {
    New-Item -Path "$path" -Name "VCList.txt" -ItemType "file"
    Write-Host "creating file"
} else {
    Clear-Content -Path "$path\VCList.txt"
    Write-Host "cleaing"
}
foreach($i in $SoftList)
{
    $x = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* , HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | 
    select DisplayName  |  Where-Object {$_.DisplayName -like $("$i*")}

    $x.DisplayName 

    $x.DisplayName | Sort-Object -Unique | Out-File "$path\VCList.txt" -Append -Force
} 

##############################################################

$2005 = "Microsoft Visual C++ 2005 Redistributable*"
$2008 = "Microsoft Visual C++ 2008 Redistributable *"
$2010 = "Microsoft Visual C++ 2010 * Redistributable *"
$2012 = "Microsoft Visual C++ 2012 Redistributable *"
$2013 = "Microsoft Visual C++ 2013 Redistributable *"
$2015 = "Microsoft Visual C++ 2015* Redistributable *"
$2017 = "Microsoft Visual C++ 2017 Redistributable *"

$path = "C:\Users\aes\Desktop\SupportTools\VC++"

#$SoftList =  @("$2005", "$2008", "$2010", "$2012", "$2013", "$2015", "$2017")
$SoftList =  @("$2015")

foreach($i in $SoftList)
{
    $x = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* , HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | 
    select DisplayName , UninstallString |  Where-Object {$_.DisplayName -like $("$i*")}
    $x.UninstallString 
    $uninst = $x.UninstallString 
     
} 
foreach ($y in $uninst){
 
    #$newuninst = $y -replace "msiexec.exe", "" -Replace "/I", "" -Replace "/X", "" -replace "/uninstall", ""
    #$newuninst = $uninst.Trim()
    #Write-Host "Uninstalling - " + "$uninst`r`n" 
    #cmd /c $uninst /uninstall /quiet
    $newuninst = cmd /c $y "/quiet" "/norestart"
}

##############################################################

[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
$form = New-Object System.Windows.Forms.Form
$flowlayoutpanel = New-Object System.Windows.Forms.FlowLayoutPanel
$buttonOK = New-Object System.Windows.Forms.Button


$x = Get-ChildItem HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\ , HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\ | 
Get-ItemProperty  | Where-Object { 
    ($_.Displayname -like "Microsoft Visual C++ 2005 Redistributable*") -or
    ($_.Displayname -like "Microsoft Visual C++ 2008 Redistributable *") -or
    ($_.Displayname -like "Microsoft Visual C++ 2010 * Redistributable *") -or
    ($_.Displayname -like "Microsoft Visual C++ 2012 Redistributable *") -or
    ($_.Displayname -like "Microsoft Visual C++ 2013 Redistributable *") -or
    ($_.Displayname -like "Microsoft Visual C++ 2015* Redistributable *") -or
    ($_.Displayname -like "Microsoft Visual C++ 2017 Redistributable *")
} | Select-Object Displayname, UninstallString  


$uninst = $x.UninstallString    

$usernames = @($x.Displayname) | Sort-Object -Unique
$totalvalues = ($usernames.count)

$formsize = 85 + (30 * $totalvalues)
$flowlayoutsize = 10 + (30 * $totalvalues)
$buttonplacement = 40 + (30 * $totalvalues)
$script:CheckBoxArray = @()
    
$form_Load = {
    foreach ($user in $usernames) {
        $DynamicCheckBox = New-object System.Windows.Forms.CheckBox

        $DynamicCheckBox.Margin = '10, 8, 0, 0'
        $DynamicCheckBox.Name = $user
        #changed to make the text look better
        $DynamicCheckBox.Size = '400, 22' 
        $DynamicCheckBox.Text = "" + $user

        $DynamicCheckBox.TextAlign = 'MiddleLeft'
        $flowlayoutpanel.Controls.Add($DynamicCheckBox)
        $script:CheckBoxArray += $DynamicCheckBox
    }       
}
    
$form.Controls.Add($flowlayoutpanel)
$form.Controls.Add($buttonOK)
$form.AcceptButton = $buttonOK
$form.AutoScaleDimensions = '8, 17'
$form.AutoScaleMode = 'Font'
$form.ClientSize = "600 , $formsize"
$form.FormBorderStyle = 'FixedDialog'
$form.Margin = '5, 5, 5, 5'
$form.MaximizeBox = $False
$form.MinimizeBox = $False
$form.Name = 'form1'
$form.StartPosition = 'CenterScreen'
$form.Text = 'VC++'
$form.add_Load($($form_Load))

$flowlayoutpanel.BorderStyle = 'FixedSingle'

$flowlayoutpanel.Location = '48, 13'
$flowlayoutpanel.Margin = '4, 4, 4, 4'
$flowlayoutpanel.Name = 'flowlayoutpanel1'
$flowlayoutpanel.AccessibleName = 'flowlayoutpanel1'
$flowlayoutpanel.Size = "500, $flowlayoutsize"
$flowlayoutpanel.TabIndex = 1
    
$buttonOK.Anchor = 'Bottom, Right'
$buttonOK.DialogResult = 'OK'
$buttonOK.Location = "383, $buttonplacement"
$buttonOK.Margin = '4, 4, 4, 4'
$buttonOK.Name = 'buttonOK'
$buttonOK.Size = '100, 30'
$buttonOK.TabIndex = 0
$buttonOK.Text = '&OK'

$form.ShowDialog()


foreach ($cbox in $CheckBoxArray) {
    if ($cbox.CheckState -eq "Unchecked") {
           
    }
    elseif ($cbox.CheckState -eq "Checked") {
        $Uninstname = (Compare-Object -DifferenceObject $x.displayname -ReferenceObject $cbox.Name -CaseSensitive -ExcludeDifferent -IncludeEqual | Select-Object InputObject).InputObject
        $tobiivers = Get-ChildItem HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\ , HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\ | Get-ItemProperty  | Where-Object {   ($_.Displayname -eq "$Uninstname")  } | Select-Object Displayname, UninstallString
        $uninst = $tobiivers.UninstallString
        write-hoste "Removing: $cbox.Name `r`n"
        cmd /c $uninst "/quiet" "/norestart"

    }
}

Remove-Variable checkbox*