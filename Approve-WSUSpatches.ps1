<#
.Synopsis
   Approve updates in WSUS after the supplied date
.DESCRIPTION
   Approve updates in WSUS after the supplied date
.EXAMPLE
   Approve-WSUSpatches -DateYYYYMMDD 20211201
.EXAMPLE
   Approve-WSUSpatches -Date $date -UpdateServer 
.INPUTS
   NONE
.OUTPUTS
   NONE
.NOTES
   General notes
#>
function Approve-WSUSpatches
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
    )

    Begin
    {
        #set vars
        $logDate = Get-Date -Format yyyyMMdd_HHmm

        #logging
        Start-Transcript -Path "C:\Temp\Logs\$($MyInvocation.MyCommand.name)_$logDate.txt" | Out-Null

        Write-Verbose "BEGIN $($MyInvocation.mycommand.name)"

        if ($pscmdlet.ShouldProcess("$WSUSServer", "Get-WsusServer"))
        {
            try
            {
                $UpdateServer = Get-WsusServer $WSUSServer -PortNumber 8530
            }
            catch
            {
                Write-Error -Message "Update server unreachable"
                return 0
            }
        }

        $formattedDate = ($DateYYYYMMDD.Insert(4,"/")).Insert(7,"/")
        try
        {
            $Date = Get-Date -Date $formattedDate
        }
        catch
        {
            Write-Error -Message "Supplied date is not formatted correctly"
            return 0
        }
    }
    Process
    {
        Write-Verbose "PROCESS $($MyInvocation.mycommand.name)"

        if ($pscmdlet.ShouldProcess($UpdateServer.Name, "Retreiving all updates"))
        {
            $updates = $UpdateServer.GetUpdates() 
        }

        if ($pscmdlet.ShouldProcess($UpdateServer.name, "Retreiving relevant updates"))
        {
            $updatesAPPROVE = ($updates | Where-Object {$_.IsDeclined -eq $false -and $_.CreationDate -gt $Date}) 
        }

        $approve = New-Object Microsoft.UpdateServices.Administration.AutomaticUpdateApprovalAction
        $allComps = $UpdateServer.GetComputerTargetGroups() | Where-Object {$_.name -eq "All computers"}

        if ($pscmdlet.ShouldProcess($UpdateServer, "Approving relevant updates"))
        {
            foreach($updateAPPROVED in $updatesAPPROVE)
            {
                $percentage = ([int]$updatesAPPROVE.indexOf($update) / $updatesAPPROVE.count) * 100
                Write-Progress -Activity "Approving updates" -Status "$percentage % approved" -PercentComplete $percentage
                $updateAPPROVED.Approve($approve,$allComps)
            }
        }
    }
    End
    {
        Write-Verbose "END $($MyInvocation.mycommand.name)"

        Stop-Transcript | Out-Null

        Write-Verbose "EXIT $($MyInvocation.mycommand.name)"
    }
}