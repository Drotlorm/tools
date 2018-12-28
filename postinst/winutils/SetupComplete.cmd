rem Delete Sysprep response file
rem del /Q /F %windir%\Windows\Panther\unattend.xml

rem Delete the original user created on the initial installation
rem net user User /delete
rem rmdir /S /Q %SystemDrive%\Users\User

rem Restore dynamic pagefile.sys
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /f /v PagingFiles /t REG_MULTI_SZ /d "%SystemDrive%\pagefile.sys 0 0"

rem Enable back hibernation
powercfg -h on

rem Remove drivers installed in post-imaging
rem rmdir /S /Q %windir%\INF\driverpack

rem Install all Mandriva Pulse Agents
%windir%\Setup\Scripts\Pulse-Agent-windows-FULL-latest.exe /S
