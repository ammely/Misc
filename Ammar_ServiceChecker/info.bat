@echo off
SETLOCAL EnableDelayedExpansion
set i=300000
for /l %%x in (1, 1, %i%) do (
   echo !date! !time! >> C:\Users\Qa\Desktop\Service\output.txt
   FWUpgrade32.exe --auto --info-only >> C:\Users\Qa\Desktop\Service\output.txt
   echo. >> C:\Users\Qa\Desktop\Service\output.txt
   TIMEOUT /T 2
)
pause