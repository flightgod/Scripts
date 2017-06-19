$alph=@()
65..90|foreach-object{$alph+=[char]$_}
$alph

foreach ($letter in $alph) {
    Write-Host $letter
    }