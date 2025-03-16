# Function to add a new user
function Add-User {
    $username = Read-Host "Enter username"
    $password = Read-Host "Enter password" -AsSecureString
    $fullName = Read-Host "Enter full name"

    # Expiration Date (optional)
    $expirationDateInput = Read-Host "Enter account expiration date (MM/DD/YYYY), or press Enter for no expiration"
    if ($expirationDateInput) {
        $expirationDate = [datetime]::ParseExact($expirationDateInput, "MM/dd/yyyy", $null)
    } else {
        $expirationDate = $null
    }

    # Groups (optional)
    $groupInput = Read-Host "Enter groups (comma-separated), or press Enter for default group 'Users'"
    if (-not $groupInput) {
        $groupInput = "Users"
    }
    $groups = $groupInput.Split(',')

    # Create the user without -AccountNeverExpires
    New-LocalUser -Name $username -Password $password -FullName $fullName

    # Set expiration date if provided
    if ($expirationDate) {
        Set-LocalUser -Name $username -AccountExpires $expirationDate
        Write-Host "Account will expire on: $expirationDate"
    } else {
        Write-Host "Account will not expire."
    }

    # Add user to the specified groups
    foreach ($group in $groups) {
        Add-LocalGroupMember -Group $group.Trim() -Member $username
    }

    Write-Host "User $username created successfully and added to groups: $groupInput"
}

# Function to edit an existing user
function Edit-User {
    $username = Read-Host "Enter username to edit"

    # Check if user exists
    if (Get-LocalUser -Name $username) {
        $password = Read-Host "Enter new password (or press Enter to keep the same)"
        if ($password) {
            $password = ConvertTo-SecureString $password -AsPlainText -Force
            Set-LocalUser -Name $username -Password $password
            Write-Host "Password for $username updated successfully."
        }

        # Edit full name
        $fullName = Read-Host "Enter new full name (or press Enter to keep the same)"
        if ($fullName) {
            Set-LocalUser -Name $username -FullName $fullName
            Write-Host "Full name for $username updated to $fullName."
        }

        # Edit expiration date
        $expirationDateInput = Read-Host "Enter new expiration date (MM/DD/YYYY), or press Enter to keep the same"
        if ($expirationDateInput) {
            $expirationDate = [datetime]::ParseExact($expirationDateInput, "MM/dd/yyyy", $null)
            Set-LocalUser -Name $username -AccountExpires $expirationDate
            Write-Host "Account expiration for $username updated to $expirationDate."
        } else {
            Write-Host "No changes to expiration date."
        }

        # Edit groups
        $groupInput = Read-Host "Enter new groups (comma-separated), or press Enter to keep the same"
        if ($groupInput) {
            $groups = $groupInput.Split(',')
            # First, remove the user from all groups
            $existingGroups = Get-LocalUser -Name $username | Select-Object -ExpandProperty Groups
            foreach ($group in $existingGroups) {
                Remove-LocalGroupMember -Group $group -Member $username
            }
            # Add the user to the new groups
            foreach ($group in $groups) {
                Add-LocalGroupMember -Group $group.Trim() -Member $username
            }
            Write-Host "User $username added to new groups: $groupInput"
        }

    } else {
        Write-Host "User $username does not exist."
    }
}

# Function to delete an existing user
function Delete-User {
    $username = Read-Host "Enter username to delete"

    # Check if user exists
    if (Get-LocalUser -Name $username) {
        Remove-LocalUser -Name $username
        Write-Host "User $username deleted successfully."
    } else {
        Write-Host "User $username does not exist."
    }
}

# Main Menu
function Show-Menu {
    Write-Host "Choose an action:"
    Write-Host "1. Add User"
    Write-Host "2. Edit User"
    Write-Host "3. Delete User"
    Write-Host "4. Exit"
    Write-Host "5. Show all Users"
}

# Function to display all users
function Show-AllUsers {
    $users = Get-LocalUser
    if ($users) {
        Write-Host "List of all users:"
        $users | ForEach-Object {
            Write-Host "$($_.Name)"
        }
    } else {
        Write-Host "No users found."
    }
}

# Main loop
while ($true) {
    Show-Menu
    $choice = Read-Host "Enter your choice (1-5)"
    
    switch ($choice) {
        "1" { Add-User }
        "2" { Edit-User }
        "3" { Delete-User }
        "4" { 
            Write-Host "Exiting..."
            return  # This will exit the script entirely
        }
        "5" { Show-AllUsers }
        default { Write-Host "Invalid choice, please try again." }
    }
}
