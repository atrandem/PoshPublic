<#
.SYNOPSIS
    Short description
.DESCRIPTION
    Long description
.EXAMPLE
    PS C:\> <example usage>
    Explanation of what the example does
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    General notes
#>




function Start-VmBuild {
    <#
    param (
        OptionalParameters
    )
    #>

    #create vm name
        #create  name from a file created by user or RMM tool
    $vm_name = Get-Content .\vm_name.txt

    #check OS version
    $os_version = Get-Content .\os_version.txt

    #check for type of server ie sql dc
    $server_type = Get-Content .\server_type.txt

    #check for iso folder
    $iso_paths = @('C:\ISO', 'D:\ISO')
    foreach ($path in $iso_paths) {
        $test_iso_path = Test-Path -Path $iso_path
        if ($test_iso_path) {
            $iso_path = $test_iso_path

            #get iso name
            $iso_name = Get-ChildItem -Name *$os_version* -Include *.iso

            #put together for path
            $full_iso_path = "$test_iso_path\$iso_name"

            break
        }
        else {
            #log that one or both did not work
        }
    }

    #check for Hyper-V folder

    if ([string]::IsNullOrWhiteSpace($full_iso_path)) {
        #log that path is emp
        $Host.Exit()
    }
    
    #create c_drive vhdx
    $vm_c_drive = -join ($vm_name,"_C.vhdx")


    New-VM -Name $vm_name -MemoryStartupBytes 4GB -BootDevice CD -VHDPath $vm_c_drive  -Generation 2



}
