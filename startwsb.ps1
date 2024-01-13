<#
    .SYNOPSIS
        This script is used to start the wsb file in the current folder.
    .DESCRIPTION
        The script will generate a temp.ps1 in the current folder, and also a temp.wsb file in the current folder, then start the temp.wsb file.
#>

[CmdletBinding()]
param (
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [ValidateSet("en", "zh")]
    [string]
    $language = "zh",
    [Parameter()]
    [string]$script
)

# ensure the c:\temp folder, if not exist, create it.
if (-not (Test-Path -Path "C:\temp")) {
    New-Item -Path "C:\temp" -ItemType Directory -Force
}


# replace the ntuser.dat file in "C:\ProgramData\Microsoft\Windows\Containers\BaseImages\94ff5a8d-b1b9-461e-9052-9ac2cea6f398\BaseLayer\Files" by the choice of your language, for example, if user specify zh, then replace the ntuser.dat file with ntuser.dat in zh folder. please note the folder name (C:\ProgramData\Microsoft\Windows\Containers\BaseImages\94ff5a8d-b1b9-461e-9052-9ac2cea6f398\BaseLayer\Files) should be different in different machine.

$dest = "C:\ProgramData\Microsoft\Windows\Containers\BaseImages\94ff5a8d-b1b9-461e-9052-9ac2cea6f398\BaseLayer\Files\Users\WDAGUtilityAccount"

if ($language -eq "zh") {
    $src = "zh"
}
else {
    $src = "en"
}

Copy-Item -Path "$src\ntuser.dat" -Destination "$dest\ntuser.dat" -Force



# generate the temp.ps1 file in the current folder
$tempscript = @'
    # Path: temp.ps1
    # This script is used to start the wsb file in the current folder.
    if($lanauge -eq "zh"){
        . $PSScriptRoot\zh\zh.ps1
    }

    if($script){
        . $PSScriptRoot\$script.ps1
    }
'@


$tempscript | Out-File -FilePath "$PSScriptRoot\temp.ps1" -Encoding UTF8 -Force

# generate the temp.wsb file in the current folder
$template = @'
<Configuration>
<MappedFolders>
  <MappedFolder>
    <HostFolder>{{USERPROFILE}}\sandbox</HostFolder>
    <SandboxFolder>C:\sandbox</SandboxFolder>
    <ReadOnly>true</ReadOnly>
  </MappedFolder>
    <MappedFolder>
    <HostFolder>c:\temp</HostFolder>
    <SandboxFolder>C:\temp</SandboxFolder>
    <ReadOnly>false</ReadOnly>
  </MappedFolder>
</MappedFolders>
<LogonCommand>
  <Command>powershell.exe -ExecutionPolicy Bypass -File C:\sandbox\temp.ps1</Command>
</LogonCommand>
</Configuration>
'@ 

$template -replace "{{USERPROFILE}}", $env:USERPROFILEe | Out-File -FilePath "$PSScriptRoot\temp.wsb" -Encoding UTF8 -Force


Start-Process "$PSScriptRoot\temp.wsb"
