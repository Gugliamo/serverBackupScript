#source-path testing
function Test-AGSource{
    param ([string]$Path)

    #check to see if source folder exists
    if(Test-Path -Path $Path){
        Write-Host("Source path '$Path' OK.")
        #return true bool
        return $true
    } else {
        #display error message
        write-host("Source path '$Path' does not exist.")
        #return false bool
        return $false
    }
}

#destination-path testing
function Test-AGDest{
    param([string]$Path)

    #check to see if destination folder exists
    if(Test-Path -Path $Path){
        write-host("Destination path '$Path' OK.")
        #return true bool
        return $true
    } else {
        #display error message
        write-host("Destination folder '$Path' does not exist. Creating.")
        #create destination folder
        New-Item -Path (Split-Path $Path) -Name (split-path $Path -Leaf).ToString() -ItemType "directory"

        #test to see if destination folder exists again
        if(Test-Path -Path $Path){
            Write-Host("Destination folder '$Path' created.")
            return $true
        } else {
            Write-Host("Destination folder '$Path' could not be created.")
            return $false
        }
    }
}

#overall-path testing
function Test-AGPaths{
    param([string]$SrcPath, [string]$DestPath)

    #check for source folder
    if(!(Test-AGSource -Path $SrcPath)){
        return $false
    } elseif(!(Test-AGDest -Path $DestPath)) {
        return $false
    } else {
        #everything's good, return true bool
        return $true
    }
}

#create a backup with date-time
function New-AGBackup{
    param([string]$SrcPath,[string]$DestPath)

    #copy the folder from source to destination recursively, adding date and time to destination folder
    #put datetime value into variable
    $DateTime = Get-Date -Format FileDateTime

    #create folder with datetime in destination
    $DestFolder = (New-Item -Path $DestPath -ItemType Directory -Name $DateTime).ToString()

    #copy files over
    Copy-Item $SrcPath -Destination $DestFolder -Recurse

    Return $DestFolder
}

#show various folder info
function Show-AGInfo{
    param([string]$SrcPath,[string]$DestPath, [string]$DestFolder)

    #store name of source folder
    $SrcDirName = (split-path $SrcPath -Leaf).ToString()

    #display source tree
    #tree $SrcPath /F | Select-Object -Skip 2

    #show size of source and destination folders (rounded to 2 decimal points in Gb and Mb)
    "Source: {0:N2} GB" -f ((Get-ChildItem -force $SrcPath -Recurse | Measure-Object -Property Length -sum).sum /1Gb)
    "Source: {0:N2} MB" -f ((Get-ChildItem -force $SrcPath -Recurse | Measure-Object -Property Length -sum).sum /1Mb)
    "Source: " + (Get-ChildItem -force $SrcPath -Recurse | Measure-Object -Property Length -sum).sum + " Bytes"
    "Destination: {0:N2} GB" -f ((Get-ChildItem -force ($DestFolder + "\" + $SrcDirName) -Recurse | Measure-Object -Property Length -sum).sum /1Gb)
    "Destination: {0:N2} MB" -f ((Get-ChildItem -force ($DestFolder + "\" + $SrcDirName) -Recurse | Measure-Object -Property Length -sum).sum /1Mb)
    "Destination: " + (Get-ChildItem -force ($DestFolder + "\" + $SrcDirName) -Recurse | Measure-Object -Property Length -sum).sum + " Bytes"

    #item count
    "Source folder item count: " + (Get-ChildItem $SrcPath -Recurse | Measure-Object | Select-Object Count).count
    "Destination folder item count: " + (Get-ChildItem ($DestFolder + "\" + $SrcDirName) -Recurse | Measure-Object | Select-Object Count).count
}

#perform error checking to make sure all was copied
function Test-AGValidate{
    param([string]$SrcPath,[string]$DestFolder)

    #store name of source folder
    $SrcDirName = (split-path $SrcPath -Leaf).ToString()

    #check to see that source and dest folders are same size and have same item count
    $SrcSize = (Get-ChildItem -force $SrcPath -Recurse | Measure-Object -Property Length -sum).sum
    $SrcItemCount = (Get-ChildItem $SrcPath -Recurse | Measure-Object | Select-Object Count).count
    $DestSize = (Get-ChildItem -force ($DestFolder + "\" + $SrcDirName) -Recurse | Measure-Object -Property Length -sum).sum
    $DestItemCount = (Get-ChildItem ($DestFolder + "\" + $SrcDirName) -Recurse | Measure-Object | Select-Object Count).count

    if(!($SrcSize -eq $DestSize)) {
        write-host("!!ERROR!! Source and Destination folders are different sizes.`nCheck logs for details.")
    } elseif(!($SrcItemCount -eq $DestItemCount)) {
        write-host("!!ERROR!! Source and Destination folder item counts are different.`nCheck logs for details.")
    } else {
        Write-Host("Source and Destination folder sizes and item counts match.`nTask completed successfully.")
    }
}

#paths
$SrcPath = 'E:\powershellTests\source'
$DestPath = 'E:\powershellTests\destination'


#test paths
if(Test-AGPaths -SrcPath $SrcPath -DestPath $DestPath){
    #move forward with backup if all is fine and save returned folder name into a variable
    $DestFolder = New-AGBackup -SrcPath $SrcPath -DestPath $DestPath

    #show various info
    Show-AGInfo -SrcPath $SrcPath -DestPath $DestPath -DestFolder $DestFolder

    #perform validation/error checking
    Test-AGValidate -SrcPath $SrcPath -DestFolder $DestFolder

} else {
    #display error message and quit
    write-host("Quitting in 5 seconds.")
    #give host a few seconds to read error
    Start-Sleep -Second 5
    Exit
}

