# PowershellPlayground

## Basic operations

Powershell commands usually return objects (or a list of them) like when you want all files in a directory:

```ps1
Get-ChildItem generic
```

```
    Directory: /home/niklas/Documents/GitHubSSH/PowershellPlayground/generic

UnixMode         User Group         LastWriteTime         Size Name
--------         ---- -----         -------------         ---- ----
drwxr-xr-x     niklas niklas      9/27/2026 16:30         4096 example
-rwxr-xr-x     niklas niklas      9/27/2026 16:28          593 command_status.examples.ps1
-rwxr-xr-x     niklas niklas      9/27/2026 16:36         3334 command_status.ps1
-rwxr-xr-x     niklas niklas      9/27/2026 16:29          653 interactive_selection.examples.ps1
-rwxr-xr-x     niklas niklas      9/27/2026 16:29         2593 interactive_selection.ps1
```

The default formatting is a table that shows some of the properties but there are other formats that can be selected:

```ps1
# Show all available properties in a list
Get-ChildItem generic | Format-List *
# Show selected properties in a list
Get-ChildItem generic | Format-List FullName, Extension
# Show a table of selected properties
Get-ChildItem generic | Format-Table FullName, Extension
# Show one property with a custom column count
Get-ChildItem generic | Format-Wide FullName -Column 1
```

Properties of these objects can be selected or filtered using pipes:

```ps1
# Filter
Get-ChildItem generic -Recurse -File -Filter "*.ps1" | Select-Object FullName, Extension
```

```
FullName                                                                                         Extension
--------                                                                                         ---------
/home/niklas/Documents/GitHubSSH/PowershellPlayground/generic/command_status.examples.ps1        .ps1
/home/niklas/Documents/GitHubSSH/PowershellPlayground/generic/command_status.ps1                 .ps1
/home/niklas/Documents/GitHubSSH/PowershellPlayground/generic/interactive_selection.examples.ps1 .ps1
/home/niklas/Documents/GitHubSSH/PowershellPlayground/generic/interactive_selection.ps1          .ps1
```

```ps1
# Select
Get-ChildItem generic -Recurse -File -Filter "*.ps1" | Select-Object -ExpandProperty FullName
```

```
/home/niklas/Documents/GitHubSSH/PowershellPlayground/generic/command_status.examples.ps1
/home/niklas/Documents/GitHubSSH/PowershellPlayground/generic/command_status.ps1
/home/niklas/Documents/GitHubSSH/PowershellPlayground/generic/interactive_selection.examples.ps1
/home/niklas/Documents/GitHubSSH/PowershellPlayground/generic/interactive_selection.ps1
```

Its also possible to map objects to something else:

```ps1
# Filter
Get-ChildItem generic -Recurse -File -Filter "*.ps1" | ForEach-Object { $_.FullName }
```

### Find files

```ps1
Get-ChildItem ./generic/ -Recurse -File -Filter "*.ps1"
```

### Grep

TODO (`Select-String`)

## Windows

### Unblock files

Per default on some systems external files cannot be loaded, these files can be easily allowed using:

```ps1
Unblock-File -Path file.ps1
# Multiple files (TODO)
```

## Approved words for function names

```ps1
# Or run it without Where-Object to see all of them
Get-Verb | Where-Object Verb -in 'Select','Read','Choose'
```

```
Verb   AliasPrefix Group          Description
----   ----------- -----          -----------
Select sc          Common         Locates a resource in a container
Read   rd          Communications Acquires information from a source
```
