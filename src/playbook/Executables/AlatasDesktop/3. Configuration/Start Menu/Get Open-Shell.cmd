@echo off

fltmc > nul 2>&1 || (
	echo Administrator privileges are required.
	PowerShell Start -Verb RunAs '%0' 2> nul || (
		echo You must run this script as admin.
		exit /b 1
	)
	exit /b
)

ping -n 1 -4 www.example.com | find "time=" > nul 2>&1
if %errorlevel% == 1 (
	echo You must have an internet connection to use this script.
	echo Press any key to exit...
	pause > nul
	exit /b 1
)

where winget > nul 2>&1 || (
	echo WinGet is not installed, please update or install App Installer from Microsoft Store.
	echo Press any key to exit...
	pause > nul
	exit /b 1
)

cd %windir%\SystemApps
if exist "Microsoft.Windows.Search_cw5n1h2txyewy" goto existOS
if exist "Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy" goto existOS
goto skipRM

:existOS
cls & set /P c="It appears search and start are installed, would you like to disable them also? [Y/N]? "
if /I "%c%" == "Y" goto rmSSOS
if /I "%c%" == "N" goto skipRM

:rmSSOS
call "%windir%\AlatasDesktop\3. Configuration\Start Menu\Disable Start Menu and Search.cmd" /silent

:skipRM
echo]

:: Download and install Open-Shell
winget install -e --id Open-Shell.Open-Shell-Menu -h --accept-source-agreements --accept-package-agreements --force > nul
if %errorlevel% NEQ 0 (
    echo error: Open-Shell installation failed.
    pause
    exit /b 1
)

:: Download Fluent Metro theme
for /f "delims=" %%a in ('PowerShell "(Invoke-RestMethod -Uri "https://api.github.com/repos/bonzibudd/Fluent-Metro/releases/latest").assets.browser_download_url"') do (
	curl -L --output %TEMP%\skin.zip %%a
)

PowerShell -NoP -C "Expand-Archive '%TEMP%\skin.zip' -DestinationPath '%ProgramFiles%\Open-Shell\Skins'"

del /f /q %TEMP%\Open-Shell.exe > nul 2>&1
del /f /q %TEMP%\skin.zip > nul 2>&1

taskkill /f /im explorer.exe > nul 2>&1
start explorer.exe

echo Finished, changes have been applied.
pause
exit /b