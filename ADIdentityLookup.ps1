# Prompt the user for input
$input = Read-Host "Please enter a SID or Username"

# Function to check if input is a SID
function IsSID($input) {
    try {
        $sid = New-Object System.Security.Principal.SecurityIdentifier($input)
        return $true
    } catch {
        return $false
    }
}

# Determine if input is a SID or Username and fetch the corresponding information
if (IsSID $input) {
    try {
        $user = Get-ADUser -Identity $input
        Write-Host "Username for SID '$input' is: $($user.SamAccountName)"
    } catch {
        Write-Host "No user found with SID '$input'"
    }
} else {
    try {
        $user = Get-ADUser -Filter "SamAccountName -eq '$input'"
        Write-Host "SID for Username '$input' is: $($user.SID)"
    } catch {
        Write-Host "No user found with Username '$input'"
    }
}
