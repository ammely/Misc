@echo off
timeout /t 10
cmd /c "fwupgrade.exe --auto --info-only" >> sleeperoutput.txt


tasklist /FI "IMAGENAME eq Tobii.Service.exe" 2>NUL | find /I /N "Tobii.Service.exe">NUL
if "%ERRORLEVEL%"=="0" ( 
echo Tobii Service Program is running >> sleeperoutput.txt
) else ( 
@echo Tobii Service not running >> sleeperoutput.txt
)

tasklist /FI "IMAGENAME eq Tobii.EyeX.Engine.exe" 2>NUL | find /I /N "Tobii.EyeX.Engine.exe">NUL
if "%ERRORLEVEL%"=="0" ( 
echo EyeX Engine Program is running >> sleeperoutput.txt
) else ( 
@echo EyeX Engine not running >> sleeperoutput.txt
)

tasklist /FI "IMAGENAME eq Tobii.EyeX.Interaction.exe" 2>NUL | find /I /N "Tobii.EyeX.Interaction.exe">NUL
if "%ERRORLEVEL%"=="0" ( 
echo Interaction Engine Program is running >> sleeperoutput.txt
) else ( 
@echo Interaction Engine not running >> sleeperoutput.txt
)

sc.exe query "Tobii Service" | findstr STATE

if "%ERRORLEVEL%"=="0" ( 
echo Tobii Service is running >> sleeperoutput.txt
) else ( 
echo Tobii service is not running >> sleeperoutput.txt
)

sc.exe query "TobiiIS5LARGEPCEYE5" | findstr STATE

if "%ERRORLEVEL%"=="0" ( 
echo TobiiIS5LARGEPCEYE5 is running >> sleeperoutput.txt
) else ( 
echo TobiiIS5LARGEPCEYE5  is not running >> sleeperoutput.txt
)

sc.exe query "TobiiIS5GIBBONGAZE" | findstr STATE

if "%ERRORLEVEL%"=="0" ( 
echo TobiiIS5GIBBONGAZE is running >> sleeperoutput.txt
) else ( 
echo TobiiIS5GIBBONGAZE  is not running >> sleeperoutput.txt
)