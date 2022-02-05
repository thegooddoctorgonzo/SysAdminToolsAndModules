C:\Users\saslandry\Documents\Code\Projects\WSUSPatchManagement\Functions\.ps1
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
function Start-RemoteWSUSMonthlyPatches
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
        $DateYYYYMMDD,

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

        #Import cmdlets
        . .\Functions\Import-WSUSpatches.ps1
        . .\Functions\Approve-WSUSpatches.ps1


        if($PSBoundParameters.ContainsKey('Verbose'))
        {
            $scopeVerbosePreference = $true
        }
        else
        {
            $scopeVerbosePreference = $VerbosePreference
        }

        if ($pscmdlet.ShouldProcess("$WSUSServer", "Get-WsusServer"))
        {
            try{$UpdateServer = Get-WsusServer $WSUSServer -PortNumber 8530
            }
            catch{Write-Error -Message "Update server unreachable"
            exit
            }
        }

        #format date
        $formattedDate = ($DateYYYYMMDD.Insert(4,"/")).Insert(7,"/")
        try{$Date = Get-Date -Date $formattedDate
        }
        catch{Write-Error -Message "Supplied date is not formatted correctly"
            return 0
        }

        try{
            $goodPath = Test-Path -Path $Destination

            if(!($goodPath))
            {
                throw
            }
        }
        catch{Write-Error -Message "Folder path unreachable"
        return 0
        }

        #clean up file path
        $Destination.TrimEnd("/","\")
    }
    Process
    {
        Write-Verbose "PROCESS $($MyInvocation.mycommand.name)"
        
        Import-WSUSpatches -Source $Source -Verbose:$VerbosePreference
        Approve-WSUSpatches -WSUSServer $UpdateServer -Date $Date -Verbose:$VerbosePreference
        

        Start-Process -FilePath explorer.exe -ArgumentList $Source
    }
    End
    {
        Write-Verbose "END $($MyInvocation.mycommand.name)"

        Stop-Transcript

        Write-Verbose "EXIT $($MyInvocation.mycommand.name)"
    }
}