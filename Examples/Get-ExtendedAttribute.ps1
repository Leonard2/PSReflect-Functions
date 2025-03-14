function Get-IndividualExtendedAttribute
{
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'File')]
        [System.IO.FileInfo]
        $File,

        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'Directory')]
        [System.IO.DirectoryInfo]
        $Directory
    )

    try
    {
        if($PSCmdlet.ParameterSetName -eq 'Directory')
        {
            $FileMode = $FILE_DIRECTORY_FILE
            $FullName = $Directory.FullName
        }
        else
        {
            $FileMode = $FILE_NON_DIRECTORY_FILE
            $FullName = $File.FullName
        }
    
        $FileHandle = NtOpenFile -FilePath $FullName -AccessMask ($READ_CONTROL -bor $FILE_READ_EA) -ShareAccess ([System.IO.FileShare]::Delete -bor [System.IO.FileShare]::ReadWrite) -OpenOptions ($FILE_OPEN_FOR_BACKUP_INTENT -bor $FILE_RANDOM_ACCESS -bor $FileMode)

        $EA = ZwQueryEaFile -FileHandle $FileHandle
            
        if($EA -ne $null)
        {
            $EA | Add-Member -MemberType NoteProperty -Name FilePath -Value $FilePath

            Write-Output $EA
        }
    }
    catch
    {

    }
}