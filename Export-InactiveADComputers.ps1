<#

You can run the script from PowerShell. Ensure that your PowerShell session has the appropriate permissions to query Active Directory and that the AD PowerShell module is installed on the system where you're running the script.

.\GetInactiveComputers.ps1 -ou "OU=Computers,DC=example,DC=com" -daysInactive 90 -adServer "dc01.example.com"

#>

param(
    [string]$ou,           # OU to search in, e.g., "OU=Computers,DC=example,DC=com"
    [int]$daysInactive,    # Number of days to check for inactivity
    [string]$adServer      # Domain controller to query, e.g., "dc01.example.com"
)

# Importing the ActiveDirectory module
Import-Module ActiveDirectory

# Calculating the date to compare lastLogonTimestamp against
$dateCutoff = (Get-Date).AddDays(-$daysInactive)

# Converting the date to FileTime format for comparison
$fileTimeCutoff = $dateCutoff.ToFileTime()

# Querying Active Directory for computer objects in the specified OU that are inactive longer than the daysInactive
$inactiveComputers = Get-ADComputer -Filter { lastLogonTimestamp -lt $fileTimeCutoff } -Properties Name, lastLogonTimestamp, Description, DistinguishedName -SearchBase $ou -Server $adServer

# Selecting the properties to export
$computersToExport = $inactiveComputers | Select-Object Name, 
    @{Name='LastLogonDate'; Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp)}},
    Description,
    DistinguishedName

# Exporting the results to CSV
$csvPath = "InactiveComputers.csv"
$computersToExport | Export-Csv -Path $csvPath -NoTypeInformation

Write-Host "Export completed. Data saved to $csvPath"
