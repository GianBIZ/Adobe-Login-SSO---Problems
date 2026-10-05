# Adobe-Login-SSO---Problems
Know Errors and Credential issues

The fix has to be split into two scripts:

Script 1 (device): closes Adobe apps and sets iAcroLoginType = 5. Deploy it as a platform script that runs as SYSTEM, with "Run in 64-bit PowerShell" set to Yes.
Script 2 (user): clears the cached sign-ins. It must run with "Run this script using the logged on credentials" set to Yes, because each user has their own saved credentials.
Script 3 (optional): a detection script. Paired with Script 1 in Intune Remediations, it puts the registry value back if an Acrobat update removes it. Remediations need certain Windows Enterprise or Education licenses, so check your licensing before relying on it.
