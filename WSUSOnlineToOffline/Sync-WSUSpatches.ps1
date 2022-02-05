C:\Users\saslandry\Documents\Code\Projects\WSUSPatchManagement\Functions\.ps1
<#
.Synopsis
   Used to start sync of specified WSUS
.DESCRIPTION
   Long description
.EXAMPLE
   Sync-WSUSpatches
.EXAMPLE
   Sync-WSUSpatches -UpdateServer wul-vm-wsus.wisal.ibcs
.INPUTS
   NONe
.OUTPUTS
   NONE
.NOTES
   Verbose is available. WhatIf and Confirm are not

#>
function Sync-WSUSpatches
{
    [CmdletBinding(DefaultParameterSetName='Parameter Set 1', 
                  SupportsShouldProcess=$true, 
                  PositionalBinding=$false,
                  ConfirmImpact='Medium')]

    Param
    (
        # FQDN of WSUS server - default is "wul-vm-wsus.wisla.ibcs"
        [Parameter(Mandatory=$false)]
        [string]
        $WSUSServer = "wsus.domain"
    )

    Begin
    {
        #set vars
        $logDate = Get-Date -Format yyyyMMdd_HHmm

        #logging
        Start-Transcript -Path "C:\Temp\Logs\$($MyInvocation.MyCommand.name)_$logDate.txt" | Out-Null

        Write-Verbose "BEGIN $($MyInvocation.mycommand.name)"

        #get WSUS object
        if ($pscmdlet.ShouldProcess("$WSUSServer", "Get-WsusServer"))
        {
            try{$UpdateServer = Get-WsusServer $WSUSServer -PortNumber 8530
            }
            catch{"Update server unreachable"
            return 0
            }
        }
            
        
    }
    Process
    {
        Write-Verbose "PROCESS $($MyInvocation.mycommand.name)"

        if ($pscmdlet.ShouldProcess($UpdateServer, "Starting WSUS Sync"))
        {
            
            $UpdateServer.GetSubscription().StartSynchronization()

            do
            {
                Start-Sleep -Seconds 1
                $percentage = [int](($UpdateServer.GetSubscription().GetSynchronizationProgress().ProcessedItems / $UpdateServer.GetSubscription().GetSynchronizationProgress().TotalItems) * 100)
                Write-Progress -Activity "Syncing WSUS - $($UpdateServer.GetSubscription().GetSynchronizationProgress().ProcessedItems)" -Status "$percentage % Synced" -PercentComplete $percentage
            }
            while ($UpdateServer.GetSubscription().GetSynchronizationProgress().Phase -ne "NotProcessing")
        }
    }
    End
    {
        Write-Verbose "END $($MyInvocation.mycommand.name)"

        Stop-Transcript | Out-Null

        Write-Verbose "EXIT $($MyInvocation.mycommand.name)"
    }
}