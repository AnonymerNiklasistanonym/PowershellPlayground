# Helper

## Structure

- The module functions are exported in the `.psm1` (*Module*) and loaded from regular `.ps1` files
- It's important that the slashes in the imports are *Windows-like* meaning `\` instead of `/`
- The module manifest can be auto generated:

  ```ps1
  New-ModuleManifest `
      -Path "Helper\Helper.psd1" `
      -RootModule "Helper.psm1" `
      -Author "AnoymerNiklasistanonym" `
      -Description "Helper functions" `
      -ModuleVersion "0.0.1" `
      -PowerShellVersion "5.0"
  ```

  All comments and unset/empty options can be omitted

## Tests

To run tests the module `Pester` is required.
It can be installed via:

```ps1
Install-Module Pester -Scope CurrentUser
# Check/Verify install
Get-Module -ListAvailable Pester
```

```
    Directory: /home/niklas/.local/share/powershell/Modules

ModuleType Version    PreRelease Name                                PSEdition ExportedCommands
---------- -------    ---------- ----                                --------- ----------------
Script     6.2.0                 Pester                              Desk      {Invoke-Pester, Describe, Context, It…}
```

Then either run all tests or a specific file:

```ps1
Invoke-Pester
Invoke-Pester ./Tests/Format-ElapsedTime.Tests.ps1
```
