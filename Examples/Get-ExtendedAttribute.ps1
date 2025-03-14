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
            $FileMode = 'FILE_DIRECTORY_FILE'
            $FullName = "\??\" + $Directory.FullName
        }
        else
        {
            $FileMode = 'FILE_NON_DIRECTORY_FILE'
            $FullName = "\??\" + $File.FullName
        }
    
        $FileHandle = NtOpenFile -FilePath $FullName -DesiredAccess @('READ_CONTROL', 'FILE_READ_EA') -ShareAccess @('DELETE', 'READ', 'WRITE') -OpenOptions @('FILE_OPEN_FOR_BACKUP_INTENT', 'FILE_RANDOM_ACCESS', $FileMode)

        $EA = NtQueryEaFile -FileHandle $FileHandle
            
        if($EA -ne $null)
        {
            $EA | Add-Member -MemberType NoteProperty -Name FilePath -Value $FilePath

            Write-Output $EA
        }
    }
    catch
    {

    }
    finally
    {
        if($FileHandle -ne $null)
        {
            NtClose -KeyHandle $FileHandle
        }
    }
}