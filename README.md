# new-ciharddisk
New-CIHardDisk cmndlet for vCloud Director 5.5

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