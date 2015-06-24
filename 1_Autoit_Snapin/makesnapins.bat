@echo on

rem Make snapin in each directory
for /D %%a in (G-IDSS GlobalTIS) do (

   del /q /f %%a.exe

   rem Compile Aotoit script
   AutoIt\Aut2Exe\Aut2Exe.exe /in %%a\autosetup.au3 /out autosetup.exe /nopack /execlevel requireadministrator

   rem Generate Error message launcher. 
   echo if Not $CmdLine[0] Then MsgBox^(16,"Error","No argument specified. Please run as snapin.exe <Argument>"^) >launcher.au3
   AutoIt\Aut2Exe\Aut2Exe.exe /in launcher.au3 /nopack /execlevel requireadministrator

   rem Compress bundle components
   7zip\7za.exe a snapin.7z autosetup.exe .\%%a\autosetup.ini .\%%a\setup.iss launcher.exe

   rem Generate config for 7zsd.sfx Run program -- runs without /ai and Autoinstall runs if /ai is specified
   echo ;!@Install@!UTF-8! >snapin.cfg
   echo ExtractTitle="Prepare RunOnce Install" >> snapin.cfg
   echo RunProgram="launcher.exe " >> snapin.cfg
   echo AutoInstall="autosetup.exe " >> snapin.cfg
   echo SelfDelete="1" >> snapin.cfg
   echo MiscFlags="4" >> snapin.cfg
   echo ;!@InstallEnd@!@InstallEnd@! >>snapin.cfg

   rem Assembling RunOnce Snapin
   copy /b .\7zip\7zsd.sfx + .\snapin.cfg + .\snapin.7z snapin.exe

   rem Generate launcher. It will embed snapin.exe at stage of autoit compilation
   echo ^#include ^<WinAPIReg.au3^> >launcher.au3
   echo if Not $CmdLine[0] Then >>launcher.au3
   echo MsgBox^(16,"Error","No argument specified in command line. Please run as %CD%\%%a.exe <Argument>"^) >>launcher.au3
   echo Exit 1 >>launcher.au3
   echo EndIf >>launcher.au3
   echo If @OSArch = "X64" Then >>launcher.au3
   echo RegWrite^("HKLM64\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce", "FOG Snapin", "REG_SZ", "snapin.exe /ai " ^& $CmdLine[1]^) >>launcher.au3
   echo Else >>launcher.au3
   echo RegWrite^("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce", "FOG Snapin", "REG_SZ", "snapin.exe /ai " ^& $CmdLine[1]^) >>launcher.au3
   echo EndIf >>launcher.au3
   echo FileInstall^("snapin.exe", "%SystemRoot%\snapin.exe", 1^) >>launcher.au3
   AutoIt\Aut2Exe\Aut2Exe.exe /in launcher.au3 /nopack /execlevel requireadministrator

   rem Generate Error message if snapin run with /ai switch by accident
   echo MsgBox^(16,"Error","No /ai switch available. Please get rid of it and use just " ^& $CmdLine[1]^) > error.au3
   AutoIt\Aut2Exe\Aut2Exe.exe /in error.au3 /out autosetup.exe /nopack /execlevel requireadministrator

   rem Wrap Snapin components
   7zip\7za.exe a SnapWrap.7z autosetup.exe launcher.exe

   rem Assembling FOG snapin
   copy /b .\7zip\7zsd.sfx + .\snapin.cfg + .\SnapWrap.7z %%a.exe

   rem Delete stage files 
   del /q /f SnapWrap.7z snapin.cfg autosetup.exe snapin.7z snapin.exe launcher.au3 launcher.exe error.au3
)

pause