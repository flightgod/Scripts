# This is how to delete those pesky files that are too large to delete in users profile directories

# I must check path data, it might not be these. may need to look that up on the fly

$Profilename = Read-Host "Please provide the user profile name";
$path = "c:\users\" + $ProfileName + "\AppData\Local\Packages\winstore_cw5n1h2txyewy\LocalState\Cache\0"

subst x: $path
del x:\*.dat
subst x: /d

# Now delete the folder you were trying to delete
del "C:\Users\$Profilename"