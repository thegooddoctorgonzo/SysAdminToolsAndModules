
<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   General notes
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>
function Test-pscp
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

    }
    Process
    {
        Write-Verbose "PROCESS $($MyInvocation.mycommand.name)"
        $folders = Get-ChildItem -Path w:\ -Name WSUS

            Set-Location -Path w:\

            foreach($f in $folders)
            {
                $percentage = ($folders.IndexOf($f) / $folders.Count) * 100
                Write-Progress -Activity "Copying $f" -Status "$percentage % Copied" -PercentComplete $percentage
                $datefolder = Get-Date -Format yyyy-MM
                pscp -r .\$f\ acct@mntdrive:/mnt/rdx/$f/$datefolder
            }
    }
    End
    {
        Write-Verbose "END $($MyInvocation.mycommand.name)"

        Write-Verbose "EXIT $($MyInvocation.mycommand.name)"
    }
}