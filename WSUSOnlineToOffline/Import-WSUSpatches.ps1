<#
.Synopsis
   Import mothly updates from remote drive to WSUS
.DESCRIPTION
   Import mothly updates from remote drive to WSUS
.EXAMPLE
   Import-WSUSpatches -Destination z:\PATH -UpdateServer wsus.fqdn
.EXAMPLE
   
.INPUTS
   NONE
.OUTPUTS
   NONE
.NOTES
   General notes
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>
function Import-WSUSpatches
{
    [CmdletBinding(DefaultParameterSetName='Parameter Set 1', 
                  SupportsShouldProcess=$true, 
                  PositionalBinding=$false,
                  ConfirmImpact='Medium')]

    Param
    (
        # Destination file path
        [Parameter(Mandatory=$true)]
        [string]
        $Source
    )

    Begin
    {
        #set vars
        $logDate = Get-Date -Format yyyyMMdd_HHmm

        #logging
        Start-Transcript -Path "C:\Temp\Logs\$($MyInvocation.MyCommand.name)_$logDate.txt"

        Write-Verbose "BEGIN $($MyInvocation.mycommand.name)"

        if($PSBoundParameters.ContainsKey('Verbose'))
        {
            $scopeVerbosePreference = $true
        }
        else
        {
            $scopeVerbosePreference = $VerbosePreference
        }

        #test folder path
        try{
            $goodPath = Test-Path -Path $Destination

            if(!($goodPath))
            {
                throw
            }
        }
        catch{
            Write-Error -Message "File path unreachable"
            exit
        }

         #clean up folder path
        $Source.TrimEnd("/","\")
    }
    Process
    {
        Write-Verbose "PROCESS $($MyInvocation.mycommand.name)"

        if ($pscmdlet.ShouldProcess($Source, "Importing files"))
        {
            & "C:\Program Files\Update Services\Tools\wsusutil.exe" import $Source\wsusex.xml.gz $Source\wsusex.log
        }
    }
    End
    {
        Write-Verbose "END $($MyInvocation.mycommand.name)"

        Stop-Transcript

        Write-Verbose "EXIT $($MyInvocation.mycommand.name)"
    }
}