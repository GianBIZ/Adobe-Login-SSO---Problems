<#
.SYNOPSIS
  Device-level fix: closes Adobe apps and forces Acrobat to use the system
  browser for sign-in (iAcroLoginType = 5). Adobe KB "CEF-based sign-in does
  not work with Azure AD conditional access", Workaround 1.

.INTUNE
  Devices > Scripts and remediations > Platform scripts
  Run this script using the logged on credentials : No   (runs as SYSTEM)
  Enforce script signature check                  : No
  Run script in 64 bit PowerShell Host            : Yes
#>

$ErrorActionPreference = 'Stop'
$log = "$env:ProgramData\Microsoft\IntuneManagementExtension\Logs\AdobeLoginFix-Device.log"
Start-Transcript -Path $log -Append | Out-Null

try {
    # 1. Close every Adobe process (all user sessions, since this runs as SYSTEM)
    $names = 'Acrobat','AcroCEF','AcroRd32','AdobeCollabSync','AdobeIPCBroker',
             'Creative Cloud','Creative Cloud Helper','CCXProcess','CCLibrary',
             'CoreSync','Adobe Desktop Service','AdobeNotificationClient'
    Get-Process -ErrorAction SilentlyContinue |
        Where-Object { $names -contains $_.ProcessName } |
        ForEach-Object {
            Write-Output "Stopping $($_.ProcessName) (PID $($_.Id))"
            Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
        }
    Start-Sleep -Seconds 3

    # 2. Create FeatureLockDown key and set iAcroLoginType = 5
    #    Written to both the 64-bit and 32-bit registry views so it applies
    #    whether Acrobat is installed as 64-bit or 32-bit.
    $key = 'HKLM\SOFTWARE\Policies\Adobe\Adobe Acrobat\DC\FeatureLockDown'
    foreach ($view in '/reg:64','/reg:32') {
        & reg.exe add $key /v iAcroLoginType /t REG_DWORD /d 5 /f $view | Out-Null
        if ($LASTEXITCODE -ne 0) { throw "reg add failed for view $view" }
        Write-Output "Set iAcroLoginType=5 ($view)"
    }

    Write-Output 'Device fix complete.'
    exit 0
}
catch {
    Write-Error $_
    exit 1
}
finally {
    Stop-Transcript | Out-Null
}
