# Customizing your Powershell Profile

The Powershell console has a settings script that you can use to customize your experience. You can use it to load the same modules everytime you run the console, create custom commands, or customize the console itself.

If you've never worked with the different Powershell profiles, [this article](https://devblogs.microsoft.com/scripting/understanding-the-six-powershell-profiles/) explains the six different types and when each profile is used. Personally, I only use the CurrentUserAllHosts profile. I haven't found a use case where I would need the other types yet.


### Profile Template

[Click here](/exampleProfile.ps1) to view the whole profile template file.

## Profile Sections

I split my profile into different sections to keep it organized:

1. [Modules](#modules)
2. [Accelerators](#accelerators)
3. [Custom Functions](#functions)
4. [Custom Console Settings](#console-settings)

### <a id="modules">Modules</a>

```powershell
# region Modules - must be first

using module CatMods
using module ImportExcel

#endregion
```

This Modules has to be the first as the modules won't load if other commands are run before the `using` statements. This section can be used to automatically load in locally installed modules including custom modules you've written.


### <a id="accelerators">Accelerators</a>

```powershell
#region Accelerators

$type = [PowerShell].Assembly.GetType('System.Management.Automation.TypeAccelerators')
$type::Add('ArrayList', [System.Collections.ArrayList])
$type::Add('DateTimeConverter', [Management.ManagementDateTimeConverter])

#endregion
```

Powershell becomes even more versatile and powerful when you start incorporating .NET data types. The downside is, that to use those data types, you have to specify the exact location of the data type and those can get a bit convoluted. Accelerators allow you to create a shortcut keyword that you can use instead. I frequently use the `ArrayList` data type instead of the native Powershell arrays and `ArrayList` is easier to remember than `System.Collections.ArrayList`.


### <a id="functions">Custom Functions</a>

```powershell
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
```

If you run the same commands frequently, it could be in your interest to save them in a custom function. I only have a few one-liners in my profile as I created a custom module to hold the more complicated fucntions that I need.

Here are the three I use the most often:

- The `Start-PSAdmin` function starts a new Powershell console with a different account. I have it set to run using my work admin account so I can easily switch to work with something my normal work account can't access.
- The `Start-PSElevate` function starts a new elevated Powershell console. This is the same as starting Powershell with the "Run As Administrator" option from the right click menu. Frequently there are Powershell commands that require administrator-level access and this function lets me create a new console quickly.
- The `Open-GitBash` is a new function I created only a few months ago. It opens a new Windows Terminal console set to the Git Bash profile I configured and opens it to the same working directory as the Powershell console was using. Recently, I was working on a Powershell application that was stored on a server and getting to that folder in the Git Bash console was a bit of a slog. Every tab complete took 10 to 15 seconds to load. Since I usually already had a Powershell console open to that working directory, this function let me access the Git Bash significantly faster.


### <a id="console-settings">Custom Console Settings</a>

```powershell
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
```

The last section in my Powershell profile is the custom console settings. In this section you can modify environment variables, change the look of your console window, or initialize custom variables. Before I reorganized my code files, I had my custom modules stored in a different folder than the standard Powershell module folder. In order to access it, I had to modify my `PSModulePath` variable to add that folder to the list.

The only console customization I have in my profile is a function to set the title of the console window. It shows what account the console is running under, whether the console is elevated to administrator permissions, and which version of Powershell the console window is. At one point I had three different versions of Powershell installed and not all of the scripts I was running worked in all versions. Listing the version of Powershell in the console title was an easy way to differentiate between console windows.

I don't have an example here, but in a past job I had a credential securely stored in an encrypted file that my profile script decrypted into a Credential variable that I could use easier in the Powershell console. This way I didn't have to type in the very complicated password multiple times in a row. You could also use it to save some constant values that you use frequently.


## Conclusion

Powershell profiles are an easy way to up your productivity in the console. Using a scripting format you're already familiar with, you can create shortcuts and customizations for your most common commands and functions.