<# 
 .Synopsis
  Add additional HDD to vCloud Director VM instance.

 .Description
  You can add addtitonal disk to vCloud Director by specifing vm object (not string) size and storage policy.

 .Parameter vm
  VMWare vCloud object (CIVMImpl) for vCD virtual machine geted by Get-CIVM cmndlet

 .Parameter size
  Size in megabytes for new disk

 .Parameter profile
  VMWare vCenter Storage policy name that used as a storage profile in vCD, you can use this if you have vCD 5.6 and grather. But this parameter is not required.

 .Example
   New-CIHarddisk -vm $(get-CIVM -Name MyVM -Org MyOrg -OrgVdc MyVDC) -size 10240 -profile "DATA"
   Add new HDD to vm MyVM with 10Gb size from DATA storage
#>
function New-CIHarddisk
{
 [cmdletbinding()]
 param
 (
 [Parameter (ParameterSetName="pipeline",ValueFromPipeline=$true, Position=0, Mandatory=$true)]
 [PSObject]$vm,
 [Parameter (Position=1, Mandatory=$true)]
 [long]$size,
 [Parameter (Position=2, Mandatory=$false)]
 [string]$profile
 )

Process
 {
    #Write-Host "   Get VM Virtual Hardware"
    $vmHardware = $vm.ExtensionData.GetVirtualHardwareSection()

    $current_count = ($vmHardware.GetDisks().Item | where-object {$_.ResourceType.Value -eq 17}).Count

    $highaddress = ($vmHardware.item | where {$_.resourcetype.value -eq "17"} | Sort-Object addressonParent)[-1].addressonParent.value
    $addressOnParent = [int]$highaddress + 1
    $highInstance = ($vmHardware.item | where {$_.resourcetype.value -eq "17"} | Sort-Object instanceID)[-1].instanceId.value
    $instanceId = [int]$highInstance + 1
    $highElement = ($vmHardware.item | where {$_.resourcetype.value -eq "17"} | Sort-Object elementName)[-1].elementName.value
    $elementName = [int]$highElement.Split()[-1] + 1

    #Copy Last disk object
    $newhdd = $($vmHardware.Item | where {$_.resourcetype.value -eq 17})[-1]

    $newhdd.AddressOnParent.Value = $addressOnParent
    $newhdd.InstanceID.Value = $instanceId
    $newhdd.ElementName.Value = "Hard Disk $elementName"
    $newhdd.HostResource.AnyAttr[0].Value = $size

    #Construct new object for vmHardware
    $vmHardware.UpdateViewData()

    #Add previusly configured object to hardware array
    $vmHardware.Item += $newhdd
    $vmHardware.UpdateServerData()

    #Write-Host "   Check status of task."
    $vm.ExtensionData.UpdateViewData()
    $vmHardware = $vm.ExtensionData.GetVirtualHardwareSection()

    if (($vmHardware.GetDisks().Item | where-object {$_.ResourceType.Value -eq 17}).Count -gt $current_count) {
       Write-Host "   Added new HDD to CIVM "$vm.Name
    } Else {
       Write-Error "   Some Error occured during disk attachment."
       Throw "   Disk does not added to VM. Call to your hero."
    }
 }
}
Export-ModuleMember -Function New-CIHarddisk