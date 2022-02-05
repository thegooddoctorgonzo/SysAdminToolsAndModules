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
function ExportAndCopy-WSUSpatches
{
    [CmdletBinding(DefaultParameterSetName='Parameter Set 1', 
                  SupportsShouldProcess=$true, 
                  PositionalBinding=$false,
                  ConfirmImpact='Medium')]

    Param
    (
       
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
        
    }
    Process
    {
        Write-Verbose "PROCESS $($MyInvocation.mycommand.name)"

        if ($pscmdlet.ShouldProcess("Export", "metadata"))
        {
            & "C:\Program Files\Update Services\Tools\wsusutil.exe" export .\wsusex_$date.xml.gz .\wsusex_$date.log
        }

        Start-Process -FilePath "C:\Windows\explorer.exe" -ArgumentList "c:\Program Files\Update Services\Tools"

        foreach($min in (1..240))
        {
            [Int64]$percent = ($min / 240) * 100
            Write-Progress -Activity "Waiting for export" -PercentComplete $percent -Status $(($percent).ToString() + "%")
            Start-Sleep -Seconds 60 -Verbose
        }

        if ($pscmdlet.ShouldProcess("Copying files to W:\", "metadata"))
        {
            Copy-Item -Path "C:\Program Files\Update Services\Tools\wsusex_$date.xml.gz" -Destination w:\WSUS
            Copy-Item -Path "C:\Program Files\Update Services\Tools\wsusex_$date.log" -Destination w:\WSUS
        }
        
        if ($pscmdlet.ShouldProcess("Copying files to RDX", "files"))
        {
            $folders = Get-ChildItem -Path w:\ -Name * | Where-Object {$_.name -ne "Software Repository"}

            Set-Location -Path w:\

            foreach($f in $folders)
            {
                $percentage = ($folders.IndexOf($f) / $folders.Count) * 100
                Write-Progress -Activity "Copying $f" -Status "$percentage % Copied" -PercentComplete $percentage
                $datefolder = Get-Date -Format yyyy-MM
                pscp -r .\$f\ eacct@10.20.30.43:/mnt/rdx/$datefolder/$f
            }
        }
    }
    End
    {
        Write-Verbose "END $($MyInvocation.mycommand.name)"

        Stop-Transcript

        Write-Verbose "EXIT $($MyInvocation.mycommand.name)"
    }
}