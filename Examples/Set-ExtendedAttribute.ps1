function Set-ExtendedAttribute
{
    <#
    .SYNOPSIS

    .DESCRIPTION

    .NOTES

    .EXAMPLE
    #>

    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $FilePath,

        [Parameter(Mandatory = $true)]
        [string]
        $Name,

        [Parameter(Mandatory = $true)]
        [byte[]]
        $Value
    )

    if(Test-Path -Path $FilePath -PathType Container)
    {
        $FileMode = $FILE_DIRECTORY_FILE
    }
    else
    {
        $FileMode = $FILE_NON_DIRECTORY_FILE
    }

    $FileHandle = NtOpenFile -FilePath $FilePath -AccessMask ($FILE_GENERIC_WRITE -bor $FILE_WRITE_EA) -ShareAccess ([System.IO.FileShare]::Read -bor [System.IO.FileShare]::Write) -OpenOptions ($FILE_RANDOM_ACCESS -bor $FileMode)

    ZwSetEaFile -FileHandle $FileHandle -Name $Name -Value $Value
}