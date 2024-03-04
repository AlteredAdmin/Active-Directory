[CmdletBinding(SupportsShouldProcess = $true)]

[Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string] $DisabledOU,
[Parameter(Mandatory = $true)][ValidateRange(1, 999)][int]$DaysInactive,
[Parameter(Mandatory = $true)] [ValidateNotNullOrEmpty()] [string] $AD_Server,

LogMessage -Severity VERBOSE -Message "Starting Script."

# Initialize the counter for deleted computers
$Script:DeletedComputersCount = 0

# Calculate the threshold date
$Script:ThresholdDate = (Get-Date).AddDays(-$DaysInactive)

# Search for disabled computers older than the threshold date in the specified OU
$Script:Computers = Get-ADComputer -Server $Script:AD_Server -Filter { (Enabled -eq $false) -and (whenChanged -lt $ThresholdDate) } -SearchBase $DisabledOU -Properties whenChanged


foreach ($Computer in $Computers) {
    # Use SupportsShouldProcess to confirm before making changes
    # Attempt to delete the computer account
    try {
        if ($PSCmdlet.ShouldProcess($Computer.Name, "Remove-ADComputer")) {
            Remove-ADComputer -Server $Script:AD_Server -Identity $Computer.DistinguishedName -Confirm:$false -WhatIf
        }
        $Script:DeletedComputersCount++ # Increment the counter
        LogMessage -Severity "Info" -Message "Deleted computer $($Computer.Name) as it has been inactive for more than $DaysInactive days."
    }
    catch {
        LogMessage -Severity "Error" -Message "Failed to delete computer $($Computer.Name): $_"
    }
}
    

# Log the total number of deleted computers
LogMessage -Severity "Info" -Message "Total computers deleted: $Script:DeletedComputersCount"
