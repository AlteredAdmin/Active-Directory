<#

Key Points of the Script:
User Input: The script starts by asking the user to enter either a SID or a username.

SID Check: The function IsSID tries to create a SecurityIdentifier object with the input. If successful, it assumes the input is a valid SID.

Lookup Logic:

If the input is a SID, it uses Get-ADUser -Identity to fetch the user and display the username.
If the input is a username, it uses Get-ADUser -Filter to find the user by SamAccountName and display the SID.
Requirements:
This script requires the Active Directory module, which is typically available on systems that are part of a Windows domain.
It assumes that the input will either be a valid SID or a valid username. Error handling is basic, and it will notify the user if no matching record is found.
Make sure to run this script in an environment where you have the necessary permissions to query Active Directory. If you're not connected to a domain or lack sufficient privileges, the script won't work as expected.

#>



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
