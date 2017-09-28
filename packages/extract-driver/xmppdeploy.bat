REM CHANGE THE FOLLOWING PARAMETERS ACCORDING TO YOUR SETTINGS

set SERVER_ADDRESS=pulse01
set PASSWORD=s3cr3t

REM =============================================================

REM Mount network share for copying the drivers
net use * \\%SERVER_ADDRESS%\drivers /user:\drivers %PASSWORD%

REM Create the folder structure
for /f "tokens=2" %%i in ('net use ^| findstr "drivers" ^| findstr "OK"') do set DRIVE_LETTER=%%i
for /f "tokens=2,3" %%i in ('wmic os get Caption /value ^| find "="') do set WINDOWS_FOLDER=%%i %%j

for /f "tokens=2 delims==" %%i in ('wmic computersystem get manufacturer /value ^| find "="') do set "MANUF=%%i"
set MANUF=%MANUF: =_%

for /f "tokens=2 delims==" %%i in ('wmic computersystem get model /value ^| find "="') do set "MODEL=%%i"
set MODEL=%MODEL: =_%

mkdir "%DRIVE_LETTER%\%WINDOWS_FOLDER%\%MANUF%\%MODEL%"

REM Extract the drivers
ddc.exe b /target:"%DRIVE_LETTER%\%WINDOWS_FOLDER%\%MANUF%\%MODEL%"

echo " Manufacter : " %MANUF%
echo " Model : " %MODEL%
tree "%DRIVE_LETTER%\%WINDOWS_FOLDER%\%MANUF%\%MODEL%"

REM Finally unmount the network share
net use /DELETE %DRIVE_LETTER%
