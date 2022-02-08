#sources
$mapBackupSource = 'E:\powershellTests\source'
#$serverBackupSource = 
#store name of source folder for later use
$sourceFolderName = (split-path $mapBackupSource -Leaf).ToString()

#destinations
$mapBackupDestination = 'E:\powershellTests\destination'
#$serverBackupDestination = 

#TEST22

#copy the folder from source to destination recursively, adding date and time to destination folder

#put datetime value into variable
$datetime = Get-Date -Format FileDateTime
#create folder with datetime in destination
$mapBackupDestinationDated = (New-Item -Path $mapBackupDestination -ItemType Directory -Name $datetime).ToString()
#copy files over
Copy-Item $mapBackupSource -Destination $mapBackupDestinationDated -Recurse

#!!information!!
#display source tree
#tree $mapBackupSource /F | Select-Object -Skip 2

#show size of source and destination folders (rounded to 2 decimal points in Gb and Mb)
"Source: {0:N2} GB" -f ((Get-ChildItem -force $mapBackupSource -Recurse | Measure-Object -Property Length -sum).sum /1Gb)
"Source: {0:N2} MB" -f ((Get-ChildItem -force $mapBackupSource -Recurse | Measure-Object -Property Length -sum).sum /1Mb)
"Source: " + (Get-ChildItem -force $mapBackupSource -Recurse | Measure-Object -Property Length -sum).sum + " Bytes"
"Destination: {0:N2} GB" -f ((Get-ChildItem -force ($mapBackupDestinationDated + "\" + $sourceFolderName) -Recurse | Measure-Object -Property Length -sum).sum /1Gb)
"Destination: {0:N2} MB" -f ((Get-ChildItem -force ($mapBackupDestinationDated + "\" + $sourceFolderName) -Recurse | Measure-Object -Property Length -sum).sum /1Mb)
"Destination: " + (Get-ChildItem -force ($mapBackupDestinationDated + "\" + $sourceFolderName) -Recurse | Measure-Object -Property Length -sum).sum + " Bytes"

#item count
"Source folder item count: " + (Get-ChildItem $mapBackupSource -Recurse | Measure-Object | Select-Object Count).count
"Destination folder item count: " + (Get-ChildItem ($mapBackupDestinationDated + "\" + $sourceFolderName) -Recurse | Measure-Object | Select-Object Count).count

#!!error checking section!!

#check to see that source and dest folders are same size and have same item count
$sourceSize = (Get-ChildItem -force $mapBackupSource -Recurse | Measure-Object -Property Length -sum).sum
$sourceItemCount = (Get-ChildItem $mapBackupSource -Recurse | Measure-Object | Select-Object Count).count
$destinationSize = (Get-ChildItem -force ($mapBackupDestinationDated + "\" + $sourceFolderName) -Recurse | Measure-Object -Property Length -sum).sum
$destinationItemCount = (Get-ChildItem ($mapBackupDestinationDated + "\" + $sourceFolderName) -Recurse | Measure-Object | Select-Object Count).count

if($sourceSize -eq $destinationSize){
    write-host("Source and Destination folders are the same size")
}else{
    write-host("!!ERROR!! Source and Destination folders are different sizes")
}

if($sourceItemCount -eq $destinationItemCount){
    write-host("Source and Destination folder item counts are the same")
}else{
    write-host("!!ERROR!! Source and Destination folder item counts are different")
}

