# wininstall
Command Script for installing Windows 10 from a single USB device

## Overview
The solution described in this guide will create a Windows 10 deployment device. Windows deployment can be accomplished using a single USB, as described in this guide. Often USB deployment solutions describe using two USB devices; USB-A for the bootable WinPE and USB-B for the data volume containing the Windows image and additional resources. This guide will show how you can build a single USB for use when deploying Windows to PCs with just one USB port, or if you just want to do this using a single USB.

Although this solution describes a USB device, it is fairly simple to modify this script for use with a network.

The USB device will be created using the Windows ADK (Assessment and Deployment Kit). It will contain two partitions; 

* FAT32 WinPE bootable partition
* NTFS partition for the Windows 10 image and other resources, such as scripts

> ***Important***: FAT32 file system has a maximum file size of 4GB. Most Windows images are larger than 4GB and WinPE must reside on a FAT32 partition. Therefore, you will not be able to store Windows images in the WinPE partition and must store them in a separate NTFS partition, or on a network share and this is the reason we will create two partitions. Some types of USB keys will not support multiple partitions, if you encounter this issue, you will need to try a different device (external USB hard drives will always support multiple partitions).

## Requirements
* A USB device of 16GB or greater
* A technician PC with the Windows ADK installed and at least 32GB free disk space
* Sample scripts from this repository
* A Reference PC (or virtual machine)
* A Target PC (or virtual machine)
* A Windows 10 image in .wim format 

> See [this page](https://github.com/HaroldMitts/wininstall/blob/master/TechnicianPC-lab.md "Build a Technician PC and Lab Environment") for more details about Technician PC requirements 

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

### Extend the capabilities of the WinPE by adding WinPE Optional Components (OCs) using DISM

> In this example, the following OCs are added;
>
>    * WMI
>    * .Net Framework

WMI OC and its English language component

````
dism /image:"c:\mount\winpe" /add-package /packagepath:"c:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-WMI.cab"
````
````
dism /image:"c:\mount\winpe" /add-package /packagepath:"c:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-WMI_en-us.cab"
````

DotNet Framework and its English language component
````
dism /image:"c:\mount\winpe" /add-package /packagepath:"c:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-NetFx.cab"
````
````
dism /image:"c:\mount\winpe" /add-package /packagepath:"c:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-NetFx_en-us.cab"
````
### Modify the Startnet.cmd of the WinPE

Open the Startnet.cmd file using Notepad

````
notepad c:\Mount\WinPE\Windows\System32\startnet.cmd
````

Add a Call to the wininstall.cmd script - We will save winistall.cmd to the 2nd partition or a network path as discussed later in this guide.

````
winpeinit
@ECHO OFF
FOR %%i IN (C D E F G H I J K L N M O P Q R S T U V W X Y Z) DO (
    IF EXIST %%i:\scripts\wininstall.cmd (
        SET usbbroot=%%i
    )
)
call %%i:\Scripts\wininstall.cmd
````
* The first command initializes WinPE and should already exist in the Startnet.cmd.

* The second command turns off the verbose echoing of every command. This is optional, but makes usage cleaner.

* The third command is a loop to check which drive letter is assigned to the location where the ininstall.cmd script is saved. 

* The fourth command invokes the wininstall.cmd script from the drive letter discovered by the loop.

> ***Important***: When you save the file, you should close all open file handles, for example, close File Explorer or navigate out of the Mount folder or the WinPE folder. Failing to close any open file handles will cause errors when unmounting the WinPE.

## Next Steps - Review WinPE details using DISM commands

> Optional: You can verify if WinPE has been successfully modified by running the following commands and examining the output

````
dism /get-mountedimageinfo
````
````
dism /image:"c:\Mount\WinPE" /get-pesettings
````
````
dism /image:"c:\Mount\WinPE" /get-packages
````

## Next Steps - Unmount and Commit changes to WinPE, using DISM

> Save the changes you have made to WinPE

````
dism /unmount-image /mountdir:"C:\Mount\WinPE" /commit
````

> ***Note***: If you do not want to save the changes you have made, use the /discard option, for example

````
dism /unmount-image /mountdir:"C:\Mount\WinPE" /discard
````

## Next Steps - Create Bootable Media from the Custom WinPE

1. Connect the USB device to the Technician PC

2. Determine the disk number for the USB device, using Diskpart

````
Diskpart
List Disk
Exit
````

3. Create the FAT32 WinPE partition and NTFS data partition on the USB using Diskpart

> ***Warning!*** Running these commands will erase all content on the USB device.

````
Diskpart
List Disk
Select [disk number]
Clean
Create Partition Primary Size=2000 Label="WinPE"
Format Quick fs=fat32 
Assign Letter=E
Active
Create Partition Primary
Format fs=ntfs Quick Label="USB-B"
Assign Letter=F
List Volume
Exit
````
> ***Important***: in the 3rd command, enter the disk number for the USB device, in place of the [disk number] command placeholder. If you do not know the disk number, Diskpart can tell you by running `list disk` and noting the disk number.

![Disk Manager view of USB](https://github.com/HaroldMitts/wininstall/blob/master/img/USB-diskMgmt.png)

Example view of Disk Management showing the completed USB partitions

> ***Note***: You can assign any available drive letters you wish and do not need to use E and F as shown. Also, you can set the label to anything if you want to assign different description labels.

## Next Steps - Create bootable media for WinPE using makewinpemedia.cmd 

The makewinpemedia.cmd script comes built-in to the Windows ADK and generates bootable media, either an ISO file or bootable USB.

- To create an ISO (for use on a virtual machine). This example will create an ISO file named amd64.iso saved to the D drive

````
makewinpemedia /iso c:\WinPE\amd64 d:\amd64.iso
````

- To create a bootable USB

````
makewinpemedia /ufd c:\WinPE\amd64 E:
````
> ***Warning!*** Running this command will erase all content on the USB devices E partition.

## Next Steps - Deployment Resources
1. Create a Scripts folder on the 2nd partition and name it Scripts

````
MD E:\Scripts
````

2. Create an Images folder on the 2nd partition and name it Images. You may want to create a folder for both 32-bit and 64-bit

````
MD E:\Images\x86
MD E:\Images\x64
````

3. Copy the Wininstall.cmd files to the Scripts folder, for example to the E:\Scripts folder

4. Copy a Windows 10 image to the Images folder, for example to the E:\Images\x64 folder

## Next Steps - Perform an Installation of Windows 10
![Install Windows 10 using USB](https://github.com/HaroldMitts/wininstall/blob/master/img/USB-Boot.png)

1. Boot a Reference PC (or virtual PC) to the WinPE created in the steps above

2. WinPE should initialize and locate the partition where the wininstall.cmd file is located

3. Wininstall.cmd should launch and prompt to install either Windows 10 Home or Windows 10 Pro

4. Make the OS version selection and press Enter

5. When Windows installation completes, you can press and hold the power button to power down the PC or type `exit` to reboot

6. On next boot, the device will boot to the Windows Out of Box Experience (OOBE)

> ***Note***: You should boot the device to OOBE in the factory so that you can perform a final qualitiy check and so that when the end-user next boots, the device will not need to go through plug and play detect again and it will boot faster. 

7. From the first OOBE screen, press `Shift + F10` keys to open the command prompt

8. Type `devmgmt.msc` to launch Device Manager. Inpect the device drivers and update drivers if needed, then close Device Manager.

> ***Important***: Do not create a user account - that is for the end-user to do. If you do, you will need to run Sysprep to prepare the installation for the end-user again.

9. Power down the PC by holding the power button for 10 seconds or type `shutdown -s -t 0` at the command line

10. Process the device by placing it into inventory or providing it to the end-user

![Ready for inventory](https://github.com/HaroldMitts/wininstall/blob/master/img/Forklift.png)

# Additional Related Resources
Desktop manufacturing
https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/

Windows 10 DISM Command-Line Options
https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/deployment-image-servicing-and-management--dism--command-line-options 

Windows Commands
https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/windows-commands 