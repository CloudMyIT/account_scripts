Search-ADAccount -UsersOnly -SearchBase "ou=FirstOU,dc=domain,dc=com" -AccountInactive -TimeSpan 30 |
    Where-Object { $_.Enabled -eq $true }