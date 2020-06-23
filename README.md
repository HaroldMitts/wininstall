# wininstall
Command Script for installing Windows 10 from a single USB device

## Overview
The solution described in this guide will create a Windows 10 deployment device. The solution describes a USB device, however, it is fairly simple to modify this script for use with a network.

The USB device will be created using the Windows ADK. It will contain two partitions; a FAT32 WinPE bootable partition and an NTFS partition for the Windows 10 image and other resources, such as scripts.

## Requirements
* A USB device of 16GB or greater
* A technician PC with the Windows ADK installed and at least 32GB free disk space
* Sample scripts from this repository
* A Reference PC (or virtual machine)
* A Target PC (or virtual machine)
* A Windows 10 image in .wim format 

## Getting Started
1. Install the Windows ADK on your Technician PC. If you do not already have the latest Windows ADK installed (including the Windows PE add-on), you can download it from Microsoft at this link: https://docs.microsoft.com/en-us/windows-hardware/get-started/adk-install 
2. Create a new Windows PE (WinPE) using the Windows ADK. The following command will create a 64-bit custom WinPE located at c:\WinPE\amd64 and the WinPE will be named amd64

````
copype amd64 c:\WinPE\amd64
````

In this guide, I use 64-bit, but all commands are similar for 32-bit, except you need to execute the 32-bit commands. For example, the preceeding command to create a 32-bit WinPE is

````
copype x86 c:\WinPE\x86
````

3. 







dism /mount-image /imagefile:"c:\WinPE\amd64\media\sources\boot.wim" /index:1 /mountdir:"C:\Mount\WinPE"

dism /image:"c:\mount\winpe" /add-package /packagepath:"c:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-Scripting_en-us.cab"
dism /image:"c:\mount\winpe" /add-package /packagepath:"c:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-WMI.cab"
dism /image:"c:\mount\winpe" /add-package /packagepath:"c:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-WMI_en-us.cab"
dism /image:"c:\mount\winpe" /add-package /packagepath:"c:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-NetFx.cab"
dism /image:"c:\mount\winpe" /add-package /packagepath:"c:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-NetFx_en-us.cab"
dism /image:"c:\Mount\WinPE" /add-package /packagepath:"c:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-HTA.cab"
dism /image:"c:\Mount\WinPE" /add-package /packagepath:"c:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-HTA_en-us.cab"
dism /image:"c:\Mount\WinPE" /add-package /packagepath:"c:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-PowerShell.cab"
dism /image:"c:\Mount\WinPE" /add-package /packagepath:"c:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-PowerShell_en-us.cab"
dism /image:"c:\Mount\WinPE" /add-package /packagepath:"c:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-DismCmdlets.cab"
dism /image:"c:\Mount\WinPE" /add-package /packagepath:"c:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-DismCmdlets_en-us.cab"

notepad c:\Mount\PE2\Windows\System32\startnet.cmd

dism /get-mountedimageinfo
dism /image:"c:\Mount\WinPE" /get-pesettings
dism /image:"c:\Mount\WinPE" /get-packages

dism /unmount-image /mountdir:"C:\Mount\WinPE" /commit

makewinpemedia /iso c:\WinPE\amd64 d:\amd64.iso
makewinpemedia /ufd c:\WinPE\amd64 p: