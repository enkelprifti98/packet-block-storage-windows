# Packet.net block storage auto-attach PowerShell script for Windows - Enkel Prifti

# Enabling iSCSI and Multipath support on Windows.

$MSiSCSIServer = get-service -Name MSiSCSI
if ($MSiSCSIServer.status -ne "Running") {
    Write-host "iSCSI Service has not been started, starting now..."
    Set-Service -Name msiscsi -StartupType Automatic
    Start-Service msiscsi
}


$MPIOFeature = Get-WindowsFeature -Name Multipath-IO
if ($MPIOFeature.installed -ne "Installed") {
    Write-host "Multipath (MPIO) feature has not been installed, installing now... This will require a server reboot"
    Install-WindowsFeature -name Multipath-IO
    Restart-Computer -Confirm
    exit
}

$SPC3iSCSISupport = Get-MSDSMSupportedHW -VendorId MSFT2005 -ProductId iSCSIBusType_0x9
if (($SPC3iSCSISupport.VendorId -ne "MSFT2005") -and ($SPC3iSCSISupport.ProductId -ne "iSCSIBusType_0x9")) {
    Write-host "SPC-3 iSCSI support has not been enabled, enabling now... This will require a server reboot"
    New-MSDSMSupportedHW -VendorId MSFT2005 -ProductId iSCSIBusType_0x9
    Restart-Computer -Confirm
    exit
}

# Setting TLS policy required for REST API access, retrieving instance metadata, and setting the instance initiator IQN.

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$instance_metadata = Invoke-RestMethod -Uri https://metadata.packet.net/metadata

$default_iqn = Get-InitiatorPort

Set-InitiatorPort -NodeAddress $default_iqn.NodeAddress -NewNodeAddress $instance_metadata.iqn


# This loop adds target portals so that the iSCSI targets are discovered.
# It will refresh dead target portals (can happen from server restart or detachment from Packet portal) and doesn't create duplicates if target portals are already added.

For ($i=0; $i -lt ($instance_metadata.volumes | Measure-Object).count; $i++) {
    For ($j=0; $j -lt ($instance_metadata.volumes[$i].ips | Measure-Object).count; $j++) {
        New-IscsiTargetPortal -TargetPortalAddress $instance_metadata.volumes[$i].ips[$j] | out-null
    }
}


# Connecting the iSCSI discovered targets with user input.

write-output "`n`nGetting volume status...`n`n`n`n"

Update-IscsiTarget

$Discovered_Iscsi_Targets = Get-IscsiTarget

For ($i=0; $i -lt ($Discovered_Iscsi_Targets | Measure-Object).count; $i++) {
    For ($k=0; $k -lt ($instance_metadata.volumes | Measure-Object).count; $k++) {
        if ($Discovered_Iscsi_Targets[$i].nodeaddress -eq $instance_metadata.volumes[$k].iqn) {
            $matching_index = $k
            break
        }
    }
    if (($Discovered_Iscsi_Targets[$i].isconnected) -eq $true) {
        write-output  "Volume $($($instance_metadata.volumes[$matching_index].iqn)) / $($($instance_metadata.volumes[$matching_index].name)) is already connected.`n`n`n`n"
    }
    else {
        write-output "Volume $($($instance_metadata.volumes[$matching_index].iqn)) / $($($instance_metadata.volumes[$matching_index].name)) is not connected in Windows."
        $User = Read-Host -Prompt 'Would you like to connect it? [y] Yes  (default is No)'
        write-output "`n"
        if ($User -eq "y") {
            For ($j=0; $j -lt ($instance_metadata.volumes[$matching_index].ips | Measure-Object).count; $j++) {
                Connect-IscsiTarget -NodeAddress $Discovered_Iscsi_Targets[$i].nodeaddress -IsMultipathEnabled $true -TargetPortalAddress $instance_metadata.volumes[$matching_index].ips[$j] -InitiatorPortalAddress $instance_metadata.network.addresses[2].address -IsPersistent $false | out-null
            }
            write-output "Volume $($($instance_metadata.volumes[$matching_index].iqn)) / $($($instance_metadata.volumes[$matching_index].name)) is now connected with Multipath.`n`n`n`n"
        }
        else {
            write-output "Volume $($($instance_metadata.volumes[$matching_index].iqn)) / $($($instance_metadata.volumes[$matching_index].name)) was not connected.`n`n`n`n"
        }
    }
}

write-output "Updating volume status..."

Update-IscsiTarget

write-output "`n`nAttach script completed, you can manage your connected block storage volumes in Disk Management.`nYou can close this window."
