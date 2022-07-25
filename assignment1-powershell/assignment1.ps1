$logFile = "script.log"

Function Write-Log {
    Param (
        [string]
        $logEntry
    )

    if ( -Not (Test-Path $logFile)) {
        New-Item -Name $logFile -ItemType File -Path $PSScriptRoot
    }

    Add-content $logFile -value ((Get-Date -Format “MM/dd/yyyyTHH:mm:ssK”) + " " + $logEntry)
}




$settings = Get-Content './settings.json' -ErrorAction Stop | Out-String | ConvertFrom-Json

$clientId = $settings.clientId
$tenantId = $settings.tenantId
$certificate = $settings.clientCertificate

Connect-MgGraph -ClientId $clientId -TenantId $tenantId -CertificateName $certificate

Import-Module Microsoft.Graph.Users
Import-Module Microsoft.Graph.Groups

$domain = "emailpaulgleeson.onmicrosoft.com"

$createdUsers = @{}

for ($num = 1; $num -le 20; $num++) {

    $upn = "testuser$num@$domain"

    $params = @{
        AccountEnabled = $true
        DisplayName = "Test User $num"
        MailNickname = "testuser$num"
        UserPrincipalName = $upn
        PasswordProfile = @{
            ForceChangePasswordNextSignIn = $true
            Password = "xWwvJ]6NMw+bWH-d"
        }
    }

    $attempt =  New-MgUser -BodyParameter $params -ErrorAction SilentlyContinue

    if($?) {
        $createdUsers.Add($attempt.UserPrincipalName,$attempt.Id)
        Write-Log ($upn + " | User created success" )
    }
    else {
        Write-Log ($upn + " | User created failure" )
    }
}

$params = @{
	Description = "Security Group created for assignment."
	DisplayName = "Varonis Assignment Group"
	GroupTypes = @(
	)
	MailEnabled = $false
	MailNickname = "varonisassignmentgroup"
	SecurityEnabled = $true
}

$attempt = New-MgGroup -BodyParameter $params -ErrorAction SilentlyContinue

if($?) {
    Write-Log ("Varonis Assignment Group | Group created success" )
    $groupID = $attempt.Id
    foreach($upn in $createdUsers.Keys) {
        $UserId = $createdUsers.$upn

        $params = @{
            "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$UserId"
        }
        
        $attempt = New-MgGroupMemberByRef -GroupId $groupID -BodyParameter $params -ErrorAction SilentlyContinue

        if($?) {
            Write-Log ($upn + " | Member added success" )
            
        }
        else {
            Write-Log ($upn + " | Member added failure" )
        }
    }
}
else {
    Write-Log ("Varonis Assignment Group | Group created failure" )
}




