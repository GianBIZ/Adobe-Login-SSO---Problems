<#
.SYNOPSIS
  Optional detection script for Intune Remediations.
  Pair with 1-Set-AcrobatLoginType-Device.ps1 as the remediation script so the
  registry value is re-applied automatically if an update or reinstall removes it.

.INTUNE
  Devices > Scripts and remediations > Remediations > Create
  Detection script   : this file
  Remediation script : 1-Set-AcrobatLoginType-Device.ps1
  Run as logged-on credentials : No
  Run in 64-bit PowerShell     : Yes
#>

$path = 'HKLM:\SOFTWARE\Policies\Adobe\Adobe Acrobat\DC\FeatureLockDown'
try {
    $val = (Get-ItemProperty -Path $path -Name iAcroLoginType -ErrorAction Stop).iAcroLoginType
    if ($val -eq 5) {
        Write-Output "Compliant: iAcroLoginType=$val"
        exit 0
    }
    Write-Output "Non-compliant: iAcroLoginType=$val"
    exit 1
}
catch {
    Write-Output 'Non-compliant: iAcroLoginType missing'
    exit 1
}
