Import-Module posh-git
#update Git
git add .
#Get a comment here from user
$comment = Read-Host "Give me a comment to update this push:"

git commit -m "$Comment"
git push -u origin master
