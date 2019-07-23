Function New-Password { 
<#
.SYNOPSIS
    This is a simple Powershell Script to Randomely Generate a Password
.DESCRIPTION
    The script will genereate a password with the Length you imput using
    switches for the different types of characters you want. Upper (U), 
    Lower (L), Number(N), and Symbols (S)
.EXAMPLE
    New-Password 15 -U -L -N -S
.SYNTAX
    .\NewPassword <Length> [<CommonParameters>]
.ALIASES
    -U = -Upper
    -L = -Lower
    -N = -Number
    -S = -Symbol
.LINK
.PARAMETER length
    How long you want the Pasword to be
.PARAMETER Uppercase
    Uppercase Characters
#>

    [CmdletBinding()] 
    [OutputType([String])] 
 
     
    Param( 
        [Parameter(Mandatory=$True)]
        [int]$length=30, 
 
        [alias("U")] 
        [Switch]$Uppercase, 
 
        [alias("L")] 
        [Switch]$LowerCase, 
 
        [alias("N")] 
        [Switch]$Numeric, 
 
        [alias("S")] 
        [Switch]$Symbolic 
 
    ) 
 
    Begin {} 
 
    Process { 
         
        If ($Uppercase) {$CharPool += ([char[]](64..90))} 
        If ($LowerCase) {$CharPool += ([char[]](97..122))} 
        If ($Numeric) {$CharPool += ([char[]](48..57))} 
        If ($Symbolic) {$CharPool += ([char[]](33..47)) 
                       $CharPool += ([char[]](33..47))} 
         
        If ($CharPool -eq $null) { 
            Throw 'You must select at least one of the parameters "Uppercase" "LowerCase" "Numeric" or "Symbolic"' 
        } 
 
        [String]$Password =  (Get-Random -InputObject $CharPool -Count $length) -join '' 
 
    } 
     
    End { 
         
        return $Password 
     
    } 
}
