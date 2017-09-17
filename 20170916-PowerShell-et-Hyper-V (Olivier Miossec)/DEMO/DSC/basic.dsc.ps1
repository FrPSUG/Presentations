configuration BasicDsc
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
    }
 }

 BasicDsc -nodename localhost