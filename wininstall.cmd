@ECHO off
powercfg /s 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
GOTO Begin
:version
Wininstall.cmd
https://github.com/HaroldMitts/wininstall
USB Version
By: Harold Mitts
Version 1.7
June 25, 2020

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

:Win10Home
@ECHO Ready to load Windows 10 Home
PAUSE
%usbbroot%:\Scripts\Walkthrough-Deploy.bat %usbbroot%:\images\x64\home.wim
GOTO EOF

:Win10Pro
@ECHO Ready to load Windows 10 Pro
PAUSE
%usbbroot%:\Scripts\Walkthrough-Deploy.bat %usbbroot%:\images\x64\pro.wim
GOTO EOF

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
GOTO Selection

:EOF
@ECHO Done.