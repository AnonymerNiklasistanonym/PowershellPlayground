# PowershellPlayground

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
