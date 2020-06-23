@cls
@echo **********************************************************************
@echo Walkthrough-Deploy.bat
@echo   Note: Run from the reference device in the WinPE environment
@echo.
@echo.
@if %1x==x echo Re-run this program with a path to a WIM file, example:
@if %1x==x echo Walkthrough-Deploy.bat D:\WindowsWithFrenchPlusApps.wim
@if %1x==x goto END
@echo.
@echo.
@echo   Detecting the firmware mode (BIOS or UEFI). 
@echo   Note: Some PCs may support both modes. 
@echo         Verify you're booted into the correct mode before proceeding: 
wpeutil UpdateBootInfo
for /f "tokens=2* delims=	 " %%A in ('reg query HKLM\System\CurrentControlSet\Control /v PEFirmwareType') DO SET Firmware=%%B
@echo         Note: delims is a TAB followed by a space.
@echo.
if %Firmware%==0x1 echo Detected firmware mode: BIOS.
if %Firmware%==0x2 echo Detected firmware mode: UEFI.
@echo   If this is correct, press a key to continue. 
@echo.
@echo   If this is NOT correct: Press Ctrl+C to exit this script.
@echo         Type exit to reboot the PC, and then
@echo         boot the USB key using the correct firmware mode.

@echo **********************************************************************
@echo.
@echo   Partition and format the disk
@echo   CAUTION: All the data on the primary disk will be DELETED.

if %Firmware%==0x1 diskpart /s %~dp0CreatePartitions-BIOS.txt
if %Firmware%==0x2 diskpart /s %~dp0CreatePartitions-UEFI.txt

@echo.
@echo.
@echo **********************************************************************
@echo.
@echo.
@echo    Applying image
call %~dp0ApplyImage %1

@echo
@echo
@echo **********************************************************************
@echo.
@echo    Hiding the recovery tools partition
@echo.
@echo.

if %Firmware%==0x1 echo "BIOS"
if %Firmware%==0x2 echo "uefi"
if %Firmware%==0x1 diskpart /s %~dp0HideRecoveryPartitions-BIOS.txt
if %Firmware%==0x2 diskpart /s %~dp0HideRecoveryPartitions-UEFI.txt
@echo.
@echo.
@echo **********************************************************************
@echo   All done!
@echo   Disconnect the USB drive from the reference device.
@echo   Type exit to reboot.
@echo.

:END