# Path to Saved Games
$Path = "c:\Temp"

Get-ChildItem $path | ?{ $_.PSIsContainer } | Select Name

# Pick Mod File


# Ask for name to make new


# unpack mod zip to new folder
Add-Type -AssemblyName System.IO.Compression.FileSystem

$zipfile = ""
$outPath = ""
function Unzip
{
    param([string]$zipfile, [string]$outpath)

    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}