rem Delete Sysprep response file
del /Q /F %windir%\System32\sysprep\sysprep.xml

rem Delete the original user created on the initial installation
net user User /delete
net user Temp /delete
rmdir /S /Q %SystemDrive%\Users\User
rmdir /S /Q %SystemDrive%\Users\Temp

rem Restore dynamic pagefile.sys
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /f /v PagingFiles /t REG_MULTI_SZ /d "%SystemDrive%\pagefile.sys 0 0"

rem Enable back hibernation
powercfg -h on

rem Remove drivers installed in post-imaging
rmdir /S /Q %windir%\Inf\driverpack

rem Install all Mandriva Pulse Agents
%windir%\Setup\Scripts\pulse2-win32-agents-pack-noprompt.exe
