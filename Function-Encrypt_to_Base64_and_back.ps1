$EncodedText = “LVx8RhEN/GlLr7Ov649fZTY=”
$DecodedText = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($EncodedText))
$DecodedText


$Text = ‘11467c2dfc0d4b69afb3afeb8f5f6536’
$Bytes = [System.Text.Encoding]::Unicode.GetBytes($Text)
$EncodedText =[Convert]::ToBase64String($Bytes)
$EncodedText