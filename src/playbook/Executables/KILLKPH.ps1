Get-Process -Name "ProcessHacker" -EA SilentlyContinue | Stop-Process -Force -EA SilentlyContinue
Stop-Service -Name "kprocesshacker2" -Force -EA SilentlyContinue -NoWait
Start-Sleep 10
sc.exe delete "kprocesshacker2" *>$null

$settingsXml = @"
<settings>
  <setting name="EnableKph">0</setting>
</settings>
"@
$settingsFilePath = "$env:windir\System32\config\systemprofile\AppData\Roaming\Process Hacker 2\settings.xml"
$settingsDirectory = Split-Path -Path $settingsFilePath -Parent
Remove-Item -Path $settingsDirectory -Recurse -Force -EA SilentlyContinue
New-Item -Path $settingsDirectory -ItemType Directory -Force | Out-Null
$settingsXml | Set-Content -Path $settingsFilePath -Force

$userDirectories = Get-ChildItem -Path "$env:SystemDrive\Users" -Directory -Exclude "Public", "Default", "Default User", "All Users"
foreach ($userDir in $userDirectories) {
    $destinationPath = Join-Path $userDir.FullName "AppData\Roaming\Process Hacker 2\settings.xml"
    $destinationDirectory = Split-Path -Path $destinationPath -Parent
    if (!(Test-Path -Path $destinationDirectory -PathType Container)) {
        New-Item -Path $destinationDirectory -ItemType Directory -Force | Out-Null
    }
    Copy-Item -Path $settingsFilePath -Destination $destinationPath -Force
}

# Kill the window informing about process hacker during deployment
Stop-Process -name pcaui -Force -ErrorAction SilentlyContinue