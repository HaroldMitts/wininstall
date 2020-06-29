@ECHO off
powercfg /s 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
GOTO Begin
:version
Wininstall.cmd
https://github.com/HaroldMitts/wininstall
USB Version
By: Harold Mitts
Version 2.0
June 28, 2020

:Begin
FOR %%i IN (C D E F G H I J K L N M O P Q R S T U V W X Y Z) DO (
    IF EXIST %%i:\scripts\WinInstall.cmd (
        ECHO Scripts found at %%i:\Scripts 
        ECHO Ready to load Windows from %%i:\images\x64 
        SET usbbroot=%%i
    )
)

Set /p DiskSetup= Ready to erase and configure hard disk? Type (Y) to proceed or (N) to Exit to command prompt 
if %DiskSetup% == y GOTO OSSelection
if %DiskSetup% == Y GOTO OSSelection
GOTO EOF

:OSSelection
@ECHO.
@ECHO      Select (1) for Windows Home, (2) for Pro, (3) for Command Line Interface, or (4) for help.
@ECHO.
SET /P Windv=Make your selection, then press Enter: 
IF %Windv% EQU 3 GOTO CLI
IF %Windv% EQU 4 GOTO Help
@ECHO.

:SetFirmware 
for /f "tokens=2* delims=	 " %%A in ('reg query HKLM\System\CurrentControlSet\Control /v PEFirmwareType') DO SET Firmware=%%B
if %Firmware%==0x1 (
    echo Detected firmware mode: BIOS.
    echo select disk 0 > %Temp%\CreatePartiitions-BIOS.txt
    echo clean >> %Temp%\CreatePartiitions-BIOS.txt
    echo create partition primary size=100 >> %temp%\CreatePartiitions-BIOS.txt
    echo format quick fs=ntfs label="System" >> %Temp%\CreatePartiitions-BIOS.txt
    echo assign letter="S" >> %Temp%\CreatePartiitions-BIOS.txt
    echo active >> %Temp%\CreatePartiitions-BIOS.txt
    echo create partition primary >> %Temp%\CreatePartiitions-BIOS.txt
    echo shrink minimum=750 >> %Temp%\CreatePartiitions-BIOS.txt
    echo format quick fs=ntfs label="Windows" >> %Temp%\CreatePartiitions-BIOS.txt
    echo assign letter="W" >> %Temp%\CreatePartiitions-BIOS.txt
    echo create partition primary >> %Temp%\CreatePartiitions-BIOS.txt
    echo format quick fs=ntfs label="Recovery image" >> %Temp%\CreatePartiitions-BIOS.txt
    echo assign letter="R" >> %Temp%\CreatePartiitions-BIOS.txt
    echo set id=27 >> %Temp%\CreatePartiitions-BIOS.txt
    echo list volume >> %Temp%\CreatePartiitions-BIOS.txt
    echo exit >> %Temp%\CreatePartiitions-BIOS.txt
)

if %Firmware%==0x2 (
    echo Detected firmware mode: UEFI.
    echo select disk 0 > %Temp%\CreatePartitions-UEFI.txt
    echo clean >> %Temp%\CreatePartitions-UEFI.txt
    echo convert gpt >> %Temp%\CreatePartitions-UEFI.txt
    echo create partition efi size=100 >> %Temp%\CreatePartitions-UEFI.txt
    echo format quick fs=fat32 label="System" >> %Temp%\CreatePartitions-UEFI.txt
    echo assign letter="S" >> %Temp%\CreatePartitions-UEFI.txt
    echo create partition msr size=16 >> %Temp%\CreatePartitions-UEFI.txt
    echo create partition primary >> %Temp%\CreatePartitions-UEFI.txt
    echo shrink minimum=900 >> %Temp%\CreatePartitions-UEFI.txt
    echo format quick fs=ntfs label="Windows" >> %Temp%\CreatePartitions-UEFI.txt
    echo assign letter="W" >> %Temp%\CreatePartitions-UEFI.txt
    echo create partition primary >> %Temp%\CreatePartitions-UEFI.txt
    echo format quick fs=ntfs label="Recovery" >> %Temp%\CreatePartitions-UEFI.txt
    echo assign letter="R" >> %Temp%\CreatePartitions-UEFI.txt
    echo set id="de94bba4-06d1-4d40-a16a-bfd50179d6ac" >> %Temp%\CreatePartitions-UEFI.txt
    echo gpt attributes=0x8000000000000001 >> %Temp%\CreatePartitions-UEFI.txt
    echo list volume >> %Temp%\CreatePartitions-UEFI.txt
    echo exit >> %Temp%\CreatePartitions-UEFI.txt
)

if %Firmware%==0x1 diskpart /s %Temp%\CreatePartiitions-BIOS.txt
if %Firmware%==0x2 diskpart /s %Temp%\CreatePartitions-UEFI.txt

IF %Windv% EQU 1 GOTO Win10Home
IF %Windv% EQU 2 GOTO Win10Pro

echo Selection not recognized. Restarting...
GOTO Begin

:Win10Home
@ECHO Loading Windows 10 Home... This will take a few moments...
md w:\scratchdir
dism /Apply-Image /ImageFile:%usbbroot%:\images\x64\install.wim /Index:1 /ApplyDir:W:\ /scratchdir:w:\scratchdir
W:\Windows\System32\bcdboot W:\Windows /s S:
md R:\Recovery\WindowsRE
xcopy /h W:\Windows\System32\Recovery\Winre.wim R:\Recovery\WindowsRE\
W:\Windows\System32\Reagentc /Setreimage /Path R:\Recovery\WindowsRE /Target W:\Windows
W:\Windows\System32\Reagentc /info /Target W:\Windows
echo Note: Windows RE may appear as Disabled, this is OK.
GOTO HideRecovery

:Win10Pro
@ECHO Loading Windows 10 Pro... This will take a few moments...
md w:\scratchdir
dism /Apply-Image /ImageFile:%usbbroot%:\images\x64\install.wim /Index:6 /ApplyDir:W:\ /scratchdir:w:\scratchdir
W:\Windows\System32\bcdboot W:\Windows /s S:
md R:\Recovery\WindowsRE
xcopy /h W:\Windows\System32\Recovery\Winre.wim R:\Recovery\WindowsRE\
W:\Windows\System32\Reagentc /Setreimage /Path R:\Recovery\WindowsRE /Target W:\Windows
W:\Windows\System32\Reagentc /info /Target W:\Windows
echo Note: Windows RE may appear as Disabled, this is OK.
GOTO HideRecovery

:CLI
@ECHO Opening Command Shell in a new window
Start /Min cmd.exe
GOTO EOF

:Help
@ECHO *************************************** Help Section *************************************
@ECHO This script will format the hard drive and install Windows.
@ECHO You can also open a Command Shell as a new Window (Type 3) to perform custom actions.
@ECHO Type the appropriate number for the action to perform, then press the Enter key to begin.
@ECHO *************************************** End of Help **************************************
@ECHO.
GOTO OSSelection

:HideRecovery
if %Firmware%==0x1 (
    echo Detected firmware mode: BIOS.
    echo select disk 0 > %Temp%\HideRecoveryPartitions-BIOS.txt
    echo select partition 3 >> HideRecoveryPartitions-BIOS.txt
    echo set id=27 >> HideRecoveryPartitions-BIOS.txt
    echo remove >> HideRecoveryPartitions-BIOS.txt
    echo list volume >> HideRecoveryPartitions-BIOS.txt
    echo exit >> HideRecoveryPartitions-BIOS.txt
)

if %Firmware%==0x2 (
    echo Detected firmware mode: UEFI.
    echo select disk 0 > %Temp%\HideRecoveryPartitions-UEFI.txt
    echo select partition 4 >> %Temp%\HideRecoveryPartitions-UEFI.txt
    echo remove >> %Temp%\HideRecoveryPartitions-UEFI.txt
    echo set id=de94bba4-06d1-4d40-a16a-bfd50179d6ac >> %Temp%\HideRecoveryPartitions-UEFI.txt
    echo gpt attributes=0x8000000000000001 >> %Temp%\HideRecoveryPartitions-UEFI.txt
    echo list volume >> %Temp%\HideRecoveryPartitions-UEFI.txt
    echo exit >> %Temp%\HideRecoveryPartitions-UEFI.txt
)

if %Firmware%==0x1 diskpart /s %Temp%\HideRecoveryPartitions-BIOS.txt && echo Recovery Partition Hidden
if %Firmware%==0x2 diskpart /s %Temp%\HideRecoveryPartitions-UEFI.txt && echo Recovery Partition Hidden

:EOF
@ECHO Done.