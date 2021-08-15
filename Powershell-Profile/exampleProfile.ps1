# region Modules - must be first

using module CatMods
using module ImportExcel

#endregion

#region Accelerators

$type = [PowerShell].Assembly.GetType('System.Management.Automation.TypeAccelerators')
$type::Add('ArrayList', [System.Collections.ArrayList])
$type::Add('DateTimeConverter', [Management.ManagementDateTimeConverter])

#endregion

# region Custom Functions

function Start-PSAdmin ()
{
	Start-Process pwsh.exe -Credential "AD\cmohan.admin"
}

function Start-PSElevate ()
{
	Start-Process pwsh.exe -Verb RunAs
}

function Open-GitBash ()
{
    wt -p "Git Bash" -d $(pwd)
}

#endregion

# region Custom Console Settings

$env:PSModulePath += ";C:\Users\catherine.mohan\Documents\Git\WindowsPowershell\Modules"


# Check for Elevated Prompt

$wid = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$prp = new-object System.Security.Principal.WindowsPrincipal($wid)
$admin = [System.Security.Principal.WindowsBuiltInRole]::Administrator
$IsAdmin = $prp.IsInRole($admin)

if ($isAdmin)
{
    $Host.UI.RawUI.WindowTitle = "$($env:USERNAME) - Elevated - Powershell $($PSVersionTable.PSVersion.ToString())"
}
else
{
    $Host.UI.RawUI.WindowTitle = "$($env:USERNAME) - Standard - Powershell $($PSVersionTable.PSVersion.ToString())"
}

#endregion