<#
.SYNOPSIS
  User-level fix: closes the user's Adobe apps and deletes cached
  "Adobe App ..." entries from Windows Credential Manager.
  PowerShell equivalent of:
    for /F "tokens=1,* delims= " %G in ('cmdkey /list ^| findstr /c:"Adobe App "') do cmdkey /delete %H

  Credential Manager is per-user, so this MUST run as the signed-in user,
  not as SYSTEM or a separate admin account.

.INTUNE
  Devices > Scripts and remediations > Platform scripts
  Run this script using the logged on credentials : Yes
  Enforce script signature check                  : No
  Run script in 64 bit PowerShell Host            : Yes
#>

$log = "$env:LOCALAPPDATA\Temp\AdobeLoginFix-User.log"
Start-Transcript -Path $log -Append | Out-Null

# 1. Close the user's Adobe processes so cached tokens are not rewritten
$names = 'Acrobat','AcroCEF','AcroRd32','AdobeCollabSync','AdobeIPCBroker',
         'Creative Cloud','Creative Cloud Helper','CCXProcess','CCLibrary',
         'CoreSync','Adobe Desktop Service','AdobeNotificationClient'
Get-Process -ErrorAction SilentlyContinue |
    Where-Object { $names -contains $_.ProcessName } |
    Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 3

# 2. Find and delete every credential whose target contains "Adobe App "
$targets = & cmdkey.exe /list |
    Where-Object { $_ -match '^\s*Target:\s*(.+Adobe App .*)$' } |
    ForEach-Object { $Matches[1].Trim() }

if (-not $targets) {
    Write-Output 'No Adobe App credentials found.'
}
foreach ($t in $targets) {
    & cmdkey.exe "/delete:$t" | Out-Null
    Write-Output "Deleted credential: $t (exit $LASTEXITCODE)"
}

Stop-Transcript | Out-Null
exit 0
