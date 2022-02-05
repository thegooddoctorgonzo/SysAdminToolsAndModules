<#
.Synopsis
   Start management fo monthly patches
.DESCRIPTION
   This cmdlet will sync the WSUS server, approve the new patches, and export to the specified file path
.EXAMPLE
   Start-WSUSMonthylPatches -DateYYYYMMDD 20211201
.EXAMPLE
   Start-WSUSMonthylPatches -Date $date -UpdateServer wul-vm-wsus.wisla.ibcs
.INPUTS
   NONE
.OUTPUTS
   NONE
.NOTES
   General notes
#>
function Start-WSUSMonthlyPatches
{
    [CmdletBinding(DefaultParameterSetName='Parameter Set 1', 
                  SupportsShouldProcess=$true, 
                  PositionalBinding=$false,
                  ConfirmImpact='Medium')]

    Param
    (
        # FQDN of WSUS server - uses default if not specified
        [Parameter(Mandatory=$false)]
        [string]
        $WSUSServer = "wsus.domain",

        # Date - input as a [datetime] object - defaults to first day of the current month
        [Parameter(Mandatory=$false,
                ParameterSetName="DateObject")]
        [datetime]
        $Date = (Get-Date -Date ("$([int](Get-date).Month)/1/$([int](Get-date).Year)")),

        # Date - input as a string
        [Parameter(Mandatory=$false,
                ParameterSetName="DateString")]
        [string]
        $DateYYYYMMDD

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

        #logging
        Start-Transcript -Path "C:\Temp\Logs\$($MyInvocation.MyCommand.name)_$logDate.txt"

        Write-Verbose "BEGIN $($MyInvocation.mycommand.name)"

        #Import cmdlets
        . .\Functions\Sync-WSUSpatches.ps1
        . .\Functions\Approve-WSUSpatches.ps1
        . .\Functions\Export-WSUSpatches.ps1

        if($PSBoundParameters.ContainsKey('Verbose'))
        {
            $scopeVerbosePreference = $true
        }
        else
        {
            $scopeVerbosePreference = $VerbosePreference
        }

        #test wsus server connection
        if ($pscmdlet.ShouldProcess("$WSUSServer", "Get-WsusServer"))
        {
            try{Get-WsusServer $WSUSServer -PortNumber 8530
            }
            catch{Write-Error -Message "Update server unreachable"
            return 0
            }
        }

        #format date
        $formattedDate = ($DateYYYYMMDD.Insert(4,"/")).Insert(7,"/")
        try{$Date = Get-Date -Date $formattedDate
        }
        catch{Write-Error -Message "Supplied date is not formatted correctly"
            return 0
        }

        <#
        #test file path
        try{
            $goodPath = Test-Path -Path $Destination

            if(!($goodPath))
            {
                throw
            }
        }
        catch{Write-Error -Message "Folder path unreachable"
        }

        #clean up file path
        $Destination.TrimEnd("/","\")#>
    }
    Process
    {
        Write-Verbose "PROCESS $($MyInvocation.mycommand.name)"
        
        Sync-WSUSpatches -WSUSServer $WSUSServer -Verbose:$VerbosePreference
        Approve-WSUSpatches -WSUSServer $WSUSServer -Date $Date -Verbose:$VerbosePreference
        Export-WSUSpatches  -Verbose:$VerbosePreference
    }
    End
    {
        Write-Verbose "END $($MyInvocation.mycommand.name)"

        Stop-Transcript

        Write-Verbose "EXIT $($MyInvocation.mycommand.name)"
    }
}