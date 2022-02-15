#source-path testing
function Test-AGSource{
    param ([string]$Path)

    #check to see if destination folder exists
    if(Test-Path -Path $Path){
        Write-Host("Source path '$Path' OK.")
    } else {

    }
}

#destination-path testing
function Test-AGDest{
    param([string]$Path)
}

#overall-path testing
function Test-AGPaths{
    param([string]$Path)
}

#create a backup with date-time
function New-AGBackup{
    param([string]$SrcPath,[string]$DestPath)

    #copy the folder from source to destination recursively, adding date and time to destination folder
    #put datetime value into variable
    $DateTime = Get-Date -Format FileDateTime

    #create folder with datetime in destination
    $DestPathDated = (New-Item -Path $DestPath -ItemType Directory -Name $DateTime).ToString()

    #copy files over
    Copy-Item $SrcPath -Destination $DestPathDated -Recurse

    Return $DestPathDated
}

#sources
$SrcPath = 'E:\powershellTests\source'
#$serverBackupSource = 
#store name of source folder for later use
$SrcPathDirName = (split-path $SrcPath -Leaf).ToString()

#destinations
$DestPath = 'E:\powershellTests\destination'
#$serverBackupDestination = 

#check to see if source folder exists
if(Test-Path -Path $SrcPath){
    write-host("Source path '$SrcPath' OK")

    #check to see if destination folder exists
    if(Test-Path -Path $DestPath){

        #!! MOVE DestPathDated when error-checking function is complete !!
        $DestPathDated = New-AGBackup -SrcPath $SrcPath -DestPath $DestPath

    } else {
        #display error message
        write-host("Destination folder '$DestPath' does not exist. Creating.")
        #create destination folder
        New-Item -Path (Split-Path $DestPath) -Name (split-path $DestPath -Leaf).ToString() -ItemType "directory"

        #!! MOVE DestPathDated when error-checking function is complete !!
        $DestPathDated = New-AGBackup -SrcPath $SrcPath -DestPath $DestPath

    }
} else {
    #display error message
    write-host("Source path '$SrcPath' does not exist. Quitting in 5 seconds.")
    #give host a few seconds to read error
    Start-Sleep -Second 5
    Exit
}


#!!information!!
#display source tree
#tree $SrcPath /F | Select-Object -Skip 2

#show size of source and destination folders (rounded to 2 decimal points in Gb and Mb)
"Source: {0:N2} GB" -f ((Get-ChildItem -force $SrcPath -Recurse | Measure-Object -Property Length -sum).sum /1Gb)
"Source: {0:N2} MB" -f ((Get-ChildItem -force $SrcPath -Recurse | Measure-Object -Property Length -sum).sum /1Mb)
"Source: " + (Get-ChildItem -force $SrcPath -Recurse | Measure-Object -Property Length -sum).sum + " Bytes"
"Destination: {0:N2} GB" -f ((Get-ChildItem -force ($DestPathDated + "\" + $SrcPathDirName) -Recurse | Measure-Object -Property Length -sum).sum /1Gb)
"Destination: {0:N2} MB" -f ((Get-ChildItem -force ($DestPathDated + "\" + $SrcPathDirName) -Recurse | Measure-Object -Property Length -sum).sum /1Mb)
"Destination: " + (Get-ChildItem -force ($DestPathDated + "\" + $SrcPathDirName) -Recurse | Measure-Object -Property Length -sum).sum + " Bytes"

#item count
"Source folder item count: " + (Get-ChildItem $SrcPath -Recurse | Measure-Object | Select-Object Count).count
"Destination folder item count: " + (Get-ChildItem ($DestPathDated + "\" + $SrcPathDirName) -Recurse | Measure-Object | Select-Object Count).count

#!!error checking section!!

#check to see that source and dest folders are same size and have same item count
$sourceSize = (Get-ChildItem -force $SrcPath -Recurse | Measure-Object -Property Length -sum).sum
$sourceItemCount = (Get-ChildItem $SrcPath -Recurse | Measure-Object | Select-Object Count).count
$destinationSize = (Get-ChildItem -force ($DestPathDated + "\" + $SrcPathDirName) -Recurse | Measure-Object -Property Length -sum).sum
$destinationItemCount = (Get-ChildItem ($DestPathDated + "\" + $SrcPathDirName) -Recurse | Measure-Object | Select-Object Count).count

if($sourceSize -eq $destinationSize){
    write-host("Source and Destination folders are the same size")
}else{
    write-host("!!ERROR!! Source and Destination folders are different sizes.")
}

if($sourceItemCount -eq $destinationItemCount){
    write-host("Source and Destination folder item counts are the same.")
}else{
    write-host("!!ERROR!! Source and Destination folder item counts are different")
}

write-host("Task complete.")

