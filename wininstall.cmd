@ECHO off
powercfg /s 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
Start /min cmd.exe /T:8E
GOTO StartMon
:Usage
Custom Startnet.cmd file                By: Harold Mitts
Version 1.6                             June 17, 2020

USAGE: 

    1. Create a custom WinPE using the Windows ADK
    2. Mount the WinPE using DISM, for example to C:\Mount\WinPE
    3. Copy this Startnet.cmd into the C:\Mount\WinPE\Windows\System32 overwriting the existing file
    4. Close all open file handles and folders for the mounted WinPE
    5. UnMount the WinPE using DISM, committing the changes

    For USB boot WinPE, 
        A. Create a WinPE boot media using the Windows ADK and makewinpemedia.cmd

    For network method, 
        A. Load the WinPE boot.wim file to WDS Boot images or 3rd party PXE boot manager, or
            Create a WinPE boot media using the Windows ADK and makewinpemedia.cmd
        B. Connect the target PC to the network where DHCP exists
        C. Ensure a network share is configured with images saved to Images folder with subfolders for x86 and x64
        D. Ensure a network share is configured with scripts saved to Scripts folder

            Examples:   ..\Scripts      ..\Images\x64       ..\Images\x86

        E. When using network method, find the StartMon section and 
            Configure the PING command with the computername where the network share is located
            Configure the NET USE command with the appropriate path and credentials to your network share

:StartMon
ECHO Waiting for network services...
ping Server-2019 -n 2 >NUL

IF %ERRORLEVEL%==1 (
    ECHO ERROR: %ERRORLEVEL% ^(Error 1 indicates network is not found^)
    ECHO Are you running from USB?
    ECHO.
    SET /p usbmethod=Type ^(1^) ^for USB boot or ^(2^) to retry the network or ^(3^) to ^Exit to CLI 
) 

REM IF %usbmethod% == 1 ( goto Begin ) ELSE ( IF %usbmethod% == 3 ( goto EOF ) ELSE ( IF %usbmethod% == 2 GOTO StartMon ) )
IF %usbmethod% == 1 ( goto Begin ) ELSE ( IF %usbmethod% == 2 ( GOTO StartMon ) ELSE ( IF %usbmethod% == 3 GOTO EOF ) )
REM 1 goes to USB, 2 goes to retry ping, 3 exits script

ECHO Mapping network resource
NET USE Z: \\Server-2019\Share /U:Deploy Siig2112

:TechSpecDesktop
REM call TechSpecDesktop.exe

:Begin
FOR %%i IN (C D E F G H I J K L N M O P Q R S T U V W X Y Z) DO (
    IF EXIST %%i:\scripts\Walkthrough-Deploy.bat (
        ECHO Scripts found at %%i:\Scripts 
        ECHO Ready to load Windows from %%i:\images\x64 
        SET usbbroot=%%i
    )
)
:Selection
@ECHO.
@ECHO      Select (1) for Windows Home, (2) for Pro, (3) for Command Line Interface, or (4) for help.
@ECHO.
SET /P Windv=Make your selection, then press Enter: 
@ECHO.

IF %Windv% EQU 1 GOTO Win10Home
IF %Windv% EQU 2 GOTO Win10Pro
IF %Windv% EQU 3 GOTO CLI
IF %Windv% EQU 4 GOTO Help
GOTO Selection

REM =========================================================================================================
:Win10Home
@ECHO Ready to load Windows 10 Home
PAUSE
%usbbroot%\Scripts\Walkthrough-Deploy.bat %usbbroot%\images\x64\home.wim
GOTO EOF

REM =========================================================================================================
:Win10Pro
@ECHO Ready to load Windows 10 Pro
PAUSE
%usbbroot%\Scripts\Walkthrough-Deploy.bat %usbbroot%\images\x64\pro.wim
GOTO EOF

REM =========================================================================================================
:CLI
@ECHO Opening Command Shell in a new window
Start /Min cmd.exe
GOTO EOF

REM =========================================================================================================
:Help
@ECHO *************************************** Help Section *************************************
@ECHO This script will format the hard drive and install Windows.
@ECHO You can also open a Command Shell as a new Window (Type 3) to perform custom actions.
@ECHO Type the appropriate number for the action to perform, then press the Enter key to begin.
@ECHO *************************************** End of Help **************************************
@ECHO.
GOTO Selection

REM =========================================================================================================
:EOF
@ECHO Done.