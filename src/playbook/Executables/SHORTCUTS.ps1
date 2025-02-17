function New-Shortcut {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True)][ValidateNotNullOrEmpty()][string]$ShortcutPath,
        [Parameter(Mandatory = $True)][ValidateNotNullOrEmpty()][string]$Target,
        [ValidateNotNullOrEmpty()][string]$Arguments,
        [ValidateNotNullOrEmpty()][string]$Icon,
        [switch]$IfExist
    )

    if ($IfExist) {
        if (-not (Test-Path -Path $ShortcutPath -PathType Leaf)) {
            return
        }
    }

    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($ShortcutPath)
    $Shortcut.TargetPath = $Target
    if ($Icon) { $Shortcut.IconLocation = $Icon }
    if ($Arguments) { $Shortcut.Arguments = $Arguments }
    $Shortcut.Save()
}

$defaultShortcut = "$env:SystemDrive\Users\Default\Desktop\Alatas.lnk"
New-Shortcut -Icon "$env:windir\AlatasModules\Other\alatas-folder.ico,0" -Target "$env:windir\AlatasDesktop" -ShortcutPath $defaultShortcut
foreach ($user in $(Get-ChildItem -Path "$env:SystemDrive\Users" -Directory | Where-Object { 'Public' -notcontains $_.Name })) {
    Copy-Item $defaultShortcut -Destination "$($user.FullName)\Desktop" -Force
}
Copy-Item $defaultShortcut -Destination "$env:ProgramData\Microsoft\Windows\Start Menu\Programs" -Force

$runAsTI = "$env:windir\AlatasModules\Scripts\RunAsTI.cmd"
$default = "$env:windir\AlatasDesktop\8. Troubleshooting\Default"
New-Shortcut -ShortcutPath "$default Windows Services and Drivers.lnk" -Target "$runAsTI" -Arguments "$env:windir\AlatasModules\Other\winServices.reg" -Icon "$env:windir\regedit.exe,1"
New-Shortcut -ShortcutPath "$default Alatas Services and Drivers.lnk" -Target "$runAsTI" -Arguments "$env:windir\AlatasModules\Other\alatasServices.reg" -Icon "$env:windir\regedit.exe,1"

# Fix Windows Tools shortcut in Windows 11
$shortcutPath = "$env:appdata\Microsoft\Windows\Start Menu\Programs\Administrative Tools.lnk"
$newTargetPath = "$env:windir\explorer.exe"
$newArgs = "shell:::{D20EA4E1-3957-11d2-A40B-0C5020524153}"
New-Shortcut -ShortcutPath $shortcutPath -Target $newTargetPath -Arguments $newArgs -IfExist