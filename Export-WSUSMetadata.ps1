function Test-FileLock {
    param ([parameter(Mandatory=$true)][string]$Path)

$oFile = New-Object System.IO.FileInfo $Path

if ((Test-Path -Path $Path) -eq $false)
{
  return $false
}

try
{
    $oStream = $oFile.Open([System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None)
    if ($oStream)
    {
      $oStream.Close()
    }
    $false
}
catch
{
  # file is locked by a process.
  return $true
}
}

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
function Export-WSUSMetadata
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
        
        do {
            Start-Sleep -Seconds 10
            Write-Output -InputObject "Still exporting..."
            $fileLocked = Test-FileLock -Path "C:\Program Files\Update Services\Tools\wsusex_$date.xml.gz" 
        } while ($fileLocked)

        Start-Process -FilePath "C:\Windows\explorer.exe" -ArgumentList "c:\Program Files\Update Services\Tools"
    }
    End
    {
        Write-Verbose "END $($MyInvocation.mycommand.name)"

        Stop-Transcript | Out-Null

        Write-Verbose "EXIT $($MyInvocation.mycommand.name)"
    }
}