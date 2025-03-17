function NtOpenFile
{
    <#
    .SYNOPSIS

    Opens an existing file, device, directory, or volume, and returns a handle for the file object.

    .NOTES

    (func ntdll NtOpenFile ([UInt32]) @(
        [IntPtr].MakeByRefType(),           #_Out_ PHANDLE            FileHandle
        [UInt32],                           #_In_  ACCESS_MASK        DesiredAccess
        $OBJECT_ATTRIBUTES.MakeByRefType(), #_In_  POBJECT_ATTRIBUTES ObjectAttributes
        $IO_STATUS_BLOCK.MakeByRefType(),   #_Out_ PIO_STATUS_BLOCK   IoStatusBlock
        [System.IO.FileShare],              #_In_  ULONG              ShareAccess
        [UInt32]                            #_In_  ULONG              OpenOptions
    ) -EntryPoint NtOpenFile)

    .LINK

    https://learn.microsoft.com/en-us/windows/win32/api/winternl/nf-winternl-ntopenfile

    #>

    param
    (
        [Parameter(Mandatory = $true)]
        [String]
        $FilePath,

        [Parameter(Mandatory = $true)]
        [ValidateSet('QueryDeviceOnly','FILE_READ_DATA','FILE_WRITE_DATA','FILE_APPEND_DATA','FILE_READ_EA','FILE_WRITE_EA','FILE_EXECUTE','FILE_DELETE_CHILD','FILE_READ_ATTRIBUTES','FILE_WRITE_ATTRIBUTES','SPECIFIC_RIGHTS_ALL','DELETE','READ_CONTROL','STANDARD_RIGHTS_READ','STANDARD_RIGHTS_WRITE','STANDARD_RIGHTS_EXECUTE','WRITE_DAC','WRITE_OWNER','STANDARD_RIGHTS_REQUIRED','SYNCHRONIZE','STANDARD_RIGHTS_ALL','ACCESS_SYSTEM_SECURITY','MAXIMUM_ALLOWED','GENERIC_ALL','GENERIC_EXECUTE','GENERIC_WRITE','GENERIC_READ')]
        [String[]]
        $DesiredAccess,

        [Parameter()]
        [ValidateSet('NONE','READ','WRITE','DELETE')]
        [String[]]
        $ShareAccess = 'NONE',

        [Parameter()]
        [ValidateSet('FILE_DIRECTORY_FILE', 'FILE_WRITE_THROUGH', 'FILE_SEQUENTIAL_ONLY', 'FILE_NO_INTERMEDIATE_BUFFERING', 'FILE_SYNCHRONOUS_IO_ALERT', 'FILE_SYNCHRONOUS_IO_NONALERT', 'FILE_NON_DIRECTORY_FILE', 'FILE_CREATE_TREE_CONNECTION', 'FILE_COMPLETE_IF_OPLOCKED', 'FILE_NO_EA_KNOWLEDGE', 'FILE_OPEN_REMOTE_INSTANCE', 'FILE_RANDOM_ACCESS', 'FILE_DELETE_ON_CLOSE', 'FILE_OPEN_BY_FILE_ID', 'FILE_OPEN_FOR_BACKUP_INTENT', 'FILE_NO_COMPRESSION', 'FILE_OPEN_REQUIRING_OPLOCK', 'FILE_DISALLOW_EXCLUSIVE', 'FILE_SESSION_AWARE', 'FILE_RESERVE_OPFILTER', 'FILE_OPEN_REPARSE_POINT', 'FILE_OPEN_NO_RECALL', 'FILE_OPEN_FOR_FREE_SPACE_QUERY', 'FILE_CONTAINS_EXTENDED_CREATE_INFORMATION')]
        [String[]]
        $OpenOptions = @('FILE_NON_DIRECTORY_FILE', 'FILE_OPEN_FOR_BACKUP_INTENT', 'FILE_RANDOM_ACCESS')
    )
#>

    # Create a UNICODE_STRING for the name
    $kName = RtlInitUnicodeString -SourceString $FilePath

    # Calculate dwDesiredAccess
    [UInt32]$dwDesiredAccess = 0
    foreach($val in $DesiredAccess)
    {
        $dwDesiredAccess = $dwDesiredAccess -bor $FILE_ACCESS::$val
    }

    # Calculate dwShareMode Value
    [UInt32]$dwShareAccess = 0

    foreach($val in $ShareAcess)
    {
        $dwShareAccess = $dwShareAccess -bor $FILE_SHARE::$val
    }

    # Calculate dwOpenOptions Value
    [UInt32]$dwOpenOptions = 0

    foreach($val in $OpenOptions)
    {
        $dwOpenOptions = $dwOpenOptions -bor $FILE_OPTIONS::$val
    }

    # InitializeObjectAttributes clone
    $objectAttribute                = [Activator]::CreateInstance($OBJECT_ATTRIBUTES)
    $objectAttribute.Length         = $OBJECT_ATTRIBUTES::GetSize()
    $objectAttribute.RootDirectory  = [IntPtr]::Zero
    $objectAttribute.Attributes     = $OBJ_ATTRIBUTE::OBJ_CASE_INSENSITIVE
    $objectAttribute.ObjectName     = [System.Runtime.InteropServices.Marshal]::AllocHGlobal($UNICODE_STRING::GetSize())
    [System.Runtime.InteropServices.Marshal]::StructureToPtr($kName, $objectAttribute.ObjectName, $true)

    # These are set to NULL for default Security Settings (mirrors the InitializeObjectAttributes macro).
    $objectAttribute.SecurityDescriptor = [IntPtr]::Zero
    $objectAttribute.SecurityQualityOfService = [IntPtr]::Zero

    # Create an Instance of the IO_STATUS_BLOCK structure
    $IoStatusBlock = [Activator]::CreateInstance($IO_STATUS_BLOCK)

    $FileHandle = [IntPtr]::Zero

    $Success = $ntdll::NtOpenFile([ref]$FileHandle,
                                  $dwDesiredAccess,
                                  [ref]$objectAttribute,
                                  [ref]$IoStatusBlock,
                                  $dwShareAccess,
                                  $dwOpenOptions)
    $LastError = [Runtime.InteropServices.Marshal]::GetLastWin32Error()

    if(-not $Success)
    {
        Write-Debug "NtOpenFile Error: $(([ComponentModel.Win32Exception] $LastError).Message)"
    }
    Write-Output $FileHandle

    # Free our memory after allocation
    [System.Runtime.InteropServices.Marshal]::FreeHGlobal($objectAttribute.ObjectName)
}