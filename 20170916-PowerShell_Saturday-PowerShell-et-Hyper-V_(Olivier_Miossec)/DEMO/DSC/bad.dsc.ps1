configuration badDsc
{
    param (
           [string]$NodeName = 'localhost'
     )
 node $NodeName {       
    File Folder1
        {
           DestinationPath = 'c:\Folder1'
           Type = 'Directory'
           Ensure = 'Present'
       }
    File Folder1
        {
           DestinationPath = 'c:\Folder1'
           Type = 'Directory'
           Ensure = 'Present'
       }


 }

 }

badDsc -nodename localhost
