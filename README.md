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

3. Create a folder for mounting images. It can be any location you like, but typically I place my Mount folder in the root of the C drive

````
MD C:\Mount\WinPE
````

4. Mount the new WinPE, using [DISM](https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/dism---deployment-image-servicing-and-management-technical-reference-for-windows "Deployment Image Servicing and Management documentation at Microsoft.com" )

````
dism /mount-image /imagefile:"c:\WinPE\amd64\media\sources\boot.wim" /index:1 /mountdir:"C:\Mount\WinPE"
````

5. Extend the capabilities of the WinPE by adding WinPE Optional Components (OCs) using DISM. In this example, the following OCs are added

    * Scripting
    * WMI
    * .Net Framework
    * HTA
    * PowerShell
    * DISM Commandlets

#### From the Deployment and Imaging Tools Environment (WinPE CLI), add the WinPE OCs
Scripting OC and its English language component
````
dism /image:"c:\mount\winpe" /add-package /packagepath:"c:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-Scripting_en-us.cab"

dism /image:"c:\mount\winpe" /add-package /packagepath:"c:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-Scripting_en-us.cab"
````
WMI OC and its English language component
````
dism /image:"c:\mount\winpe" /add-package /packagepath:"c:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-WMI.cab"

dism /image:"c:\mount\winpe" /add-package /packagepath:"c:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-WMI_en-us.cab"
````
Dot Net Framework and its English language component
````
dism /image:"c:\mount\winpe" /add-package /packagepath:"c:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-NetFx.cab"

dism /image:"c:\mount\winpe" /add-package /packagepath:"c:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-NetFx_en-us.cab"
````
HTML Application (HTA) support and its English language component
````
dism /image:"c:\Mount\WinPE" /add-package /packagepath:"c:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-HTA.cab"

dism /image:"c:\Mount\WinPE" /add-package /packagepath:"c:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-HTA_en-us.cab"
````
PowerShell and its English language component
````
dism /image:"c:\Mount\WinPE" /add-package /packagepath:"c:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-PowerShell.cab"

dism /image:"c:\Mount\WinPE" /add-package /packagepath:"c:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-PowerShell_en-us.cab"
````
DISM Commandlets and its English language component
````
dism /image:"c:\Mount\WinPE" /add-package /packagepath:"c:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-DismCmdlets.cab"

dism /image:"c:\Mount\WinPE" /add-package /packagepath:"c:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-DismCmdlets_en-us.cab"
````

6. Open the Startnet.cmd file using Notepad
````
notepad c:\Mount\PE2\Windows\System32\startnet.cmd
````
7. Add a Call to the wininstall.cmd script. We will save winistall.cmd to the 2nd partition or a network path and is discussed later in this guide.
````
winpeinit
@ECHO OFF
powercfg /s 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
FOR %%i IN (C D E F G H I J K L N M O P Q R S T U V W X Y Z) DO (
    IF EXIST %%i:\scripts\wininstall.cmd (
        SET usbbroot=%%i
    )
)
call %%i:\Scripts\wininstall.cmd
````
* The first command initializes WinPE and should already exist in the Startnet.cmd.

* The second command turns off the verbose echoing of every command. This is optional, but makes usage cleaner.

* The third command sets the WinPE power scheme to high performance mode. This is optional, but will help load Windows faster.

* The fourth command is a loop to check which drive letter is assigned to the location where the ininstall.cmd script is saved. 

8. Review WinPE details using DISM commands
````
dism /get-mountedimageinfo
````
````
dism /image:"c:\Mount\WinPE" /get-pesettings
````
````
dism /image:"c:\Mount\WinPE" /get-packages
````

9. Unmount and Commit changes to WinPE, using DISM
````
dism /unmount-image /mountdir:"C:\Mount\WinPE" /commit
````

10. Connect the USB device to the Technician PC

11. Create the WinPE partition and data partition on the USB using Diskpart

> Warning! Running these commands will erase all content on the USB device.

````
Diskpart
List Disk
Select [disk number]
Clean
Create Partition Primary 
Size=2000
Format Quick fs=fat32 
Label="Windows PE"
Assign Letter=E
Active
Create Partition Primary
Format fs=ntfs Quick 
Label="Data"
Assign Letter=F
List Volume
Exit
````
> Important: in the 3rd command, enter the disk number for the USB device, in place of the [disk number] command placeholder. If you do not know the disk number, Diskpart can tell you by running `list disk` and noting the disk number.

> Note: You can assign any available drive letters you wish and do not need to use E and F as shown. Also, you can set the label to anything if you want to assign different description labels.

12. Create bootable media for WinPE using makewinpemedia.cmd (this script comes built-in to the Windows ADK)

- To create an ISO (for use on a virtual machine)

````
makewinpemedia /iso c:\WinPE\amd64 d:\amd64.iso
````

- To create a bootable USB

````
makewinpemedia /ufd c:\WinPE\amd64 p:
````