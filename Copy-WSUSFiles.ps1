<#
.Synopsis
   Export updates from specified WSUS
.DESCRIPTION
   Export updates from specified WSUS
.EXAMPLE
   Export-WSUSpatches -Destination z:\updates
.INPUTS
   NONE
.OUTPUTS
   NONE
.NOTES
   Verbose available
#>
function Copy-WSUSFiles
{
    [CmdletBinding(DefaultParameterSetName='Parameter Set 1', 
                  SupportsShouldProcess=$true, 
                  PositionalBinding=$false,
                  ConfirmImpact='Medium')]

    Param
    (
       <# Removed - path to drive is hard coded
       # Destination file path
        [Parameter(Mandatory=$true)]
        [string]
        $Destination #>
    )

    Begin
    {
        #set vars
        $logDate = Get-Date -Format yyyyMMdd_HHmm
        $datefolder = Get-Date -Format yyyy-MM

        #logging
        Start-Transcript -Path "C:\Temp\Logs\$($MyInvocation.MyCommand.name)_$logDate.txt" | Out-Null

        Write-Verbose "BEGIN $($MyInvocation.mycommand.name)"

        if($PSBoundParameters.ContainsKey('Verbose'))
        {
            $scopeVerbosePreference = $true
        }
        else
        {
            $scopeVerbosePreference = $VerbosePreference
        }
        
    }
    Process
    {
        Write-Verbose "PROCESS $($MyInvocation.mycommand.name)"

        New-Item -Path w: -Name $datefolder -ItemType Directory

        if ($pscmdlet.ShouldProcess("Copying files to W:\", "metadata"))
        {
            Move-Item -Path "C:\Program Files\Update Services\Tools\*.xml.gz" -Destination "W:\$datefolder"
            Move-Item -Path "C:\Program Files\Update Services\Tools\*.log" -Destination "W:\$datefolder"
        }

        
        if ($pscmdlet.ShouldProcess("Copying files to drive", "files"))
        {
            Set-Location -Path W:\

            $folders = Get-ChildItem -Path w:\ -Name * 


            $folders | Move-Item -Destination "W:\$datefolder"

            $groupedFolder = Get-Item -Path "W:\$datefolder\"

            pscp -r $groupedFolder acct@mntdrive:/mnt/rdx/$datefolder

            
        }
    }
    End
    {
        Write-Verbose "END $($MyInvocation.mycommand.name)"

        Stop-Transcript | Out-Null

        Write-Verbose "EXIT $($MyInvocation.mycommand.name)"
    }
}