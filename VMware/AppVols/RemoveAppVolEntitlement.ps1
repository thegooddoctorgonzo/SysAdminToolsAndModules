#$creds = Get-Credential
#$hvserver = Connect-HVServer -Server c-g6s-vcs01 -Credential $Creds
#$appPools = Get-HVApplication -HvServer $hvserver

foreach($app in $appPools)
{

    $entitlements = Get-HVEntitlement -ResourceType Application -ResourceName $app.data.Name

    foreach($ent in $entitlements)
    {
        if($ent.Base.Name -eq "C-G6S-RDS1-RemoteDesktopUsers")
        {
            Write-Host $app.Data.Name
        }
    }


}


# this removes the group from all entitlements - even if one is specified
#Remove-HVEntitlement -User "ds.amrdec.army.mil\C-G6S-RDS1-RemoteDesktopUsers" -ResourceName $scpapp -ResourceType Application -Type Group
