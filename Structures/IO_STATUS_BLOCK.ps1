$IO_STATUS_BLOCK = struct $Module IO_STATUS_BLOCK @{
    Status  = field 0 UInt32
    Pointer = field 1 IntPtr
}