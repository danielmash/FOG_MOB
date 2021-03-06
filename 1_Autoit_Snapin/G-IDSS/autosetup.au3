#include <WinAPIShPath.au3>
#include <FileConstants.au3>
#include <Misc.au3>
#include <Debug.au3>

Local $ANSWERS = @ScriptDir & "\setup.iss" ; path to install
Local $Serial = "" ; Look down for command line checks  
Local $inifile = "autosetup.ini"

Local $SF_1 = IniRead($inifile, "General", "Title", "Auto G-IDSS Snapin")
Local $sLogPath = IniRead($inifile, "Logging", "Log", "c:\autogidss.log")
Local $sSetupLog = IniRead($inifile, "Logging", "SetupLog", "c:\setup.log")
Local $SetupLocal = IniRead($inifile, "General", "Setup", "C:\Install\GIDSS\setup.exe")
Local $NetShare = IniRead($inifile, "Net", "Share", "")
Local $NetPath = IniRead($inifile, "Net", "Path", "")
Local $NetDrive = IniRead($inifile, "Net", "Drive", "X:")
Local $NetDomUser = IniRead($inifile, "Net", "User", "guest")
Local $NetPasswd = IniRead($inifile, "Net", "Pass", "")
Local $Dealer = IniRead($inifile, "License", "Dealer", "80")  

;Enable or disable debug "4" for log file "5" for notepad window. 
_DebugSetup($SF_1, True, 5, $sLogPath)

;Delete ini for security reasons but only if running compiled as exe
If StringInStr(@ScriptName, ".exe") Then FileDelete($inifile)

_DebugOut("-------Start " & $SF_1 & " Installation-------")

; Do not allow two copies to run at the same time
If _Singleton($SF_1, 1) = 0 Then
    _DebugOut("Error: This script is already running!")
    MsgBox(0, $SF_1, "Error: This script is already running!")
    Exit
EndIf

_DebugOut("Wait system boots timeout")
sleep(7000)

; Set App Name
AutoItWinSetTitle($SF_1)

Func _WinWaitActivate($title,$text,$timeout=0)
	WinWait($title,$text,$timeout)
	If Not WinActive($title,$text) Then WinActivate($title,$text)
	WinWaitActive($title,$text,$timeout)
EndFunc

If Not $CmdLine[0] Then 
   MsgBox(0, $SF_1, "No argument given as command line parameter. Exit script.")
   _DebugReport("No argument given in the command line.",0,1)
Else
   $Serial = $CmdLine[1]
EndIf

$SETUP = $NetDrive & $NetPath
_DebugOut("Trying to map " & $NetShare & " to " & $NetDrive)

If DriveMapAdd($NetDrive, $NetShare, 0, $NetDomUser, $NetPasswd) Then
   _DebugOut("Success.! Using " & $SETUP)
ElseIf Not DriveMApGet($NetDrive) Then
   Sleep(3000)
   DriveMapAdd($NetDrive, $NetShare, 0, $NetDomUser, $NetPasswd) 
   If Not DriveMApGet($NetDrive) Then $SETUP = $SetupLocal ; Give another try
   _DebugOut("Unable to mount network share. Continue with " & $SETUP)
EndIf

If Not FileExists( $SETUP ) Then
   _DebugReport("No installation media found in $SetupLocal" & $SETUP,1,1) ; Exit
EndIf

_DebugOut("Disable screensaver")
$key="HKEY_CURRENT_USER\Control Panel\Desktop"
$value="ScreenSaveActive"
If Number(RegRead($key, $value)) Then
   RegWrite($key, $value, "REG_SZ", 0)
EndIf

_DebugOut("Copy previously recorded InstallShield answer file to " & $ANSWERS)
FileInstall("setup.iss", $ANSWERS, 1) ; Aut2Exe will embed this file into .exe when compile
If @error Then _DebugReport("Problem with the answers file. Unable to copy it.",1,1)

_DebugOut("Running G-IDSS silent installation: " & $NetDrive & $NetPath & " /s /sms /f1" & $ANSWERS & " /f2" & $sSetupLog)
Run($NetDrive & $NetPath & " /s /sms /f1" & $ANSWERS)
If @error Then _DebugReport("Problem to run installer executable",1,1) ; Script will be terminated

_DebugOut("Waiting for activation 10 min and no more")
_WinWaitActivate("Activation","", 20)
Send($Dealer)
Send("{TAB}")
Send($Serial)
If Not ControlCommand("Activation", "", "[NAME:btnActivate]", "IsEnabled", "") Then
   ControlClick("Activation", "", "[NAME:btnCancel]")
   _DebugOut("License has not been accepted by activation.")
   Exit
Else
   ControlClick("Activation", "", "[NAME:btnActivate]")
EndIf
_WinWaitActivate("IDSS Application Activator","")
Send("{ENTER}")

_DebugOut("Now waiting for driver installation dialog")
_WinWaitActivate("Device Driver Installation Wizard","")
Send("{ENTER}")
_WinWaitActivate("Device Driver Installation Wizard","")
Send("{ENTER}")

_DebugOut("Web Update in progress")

_WinWaitActivate("IDSS Web Updater (3.0.11)","")
WinWaitActive("IDSS Web Updater (3.0.11)", "Updates are available.  Would you like to download them now?")
Send("{ENTER}")
_DebugOut("Just waiting until all downloads finished")
_WinWaitActivate("Your system is now updated", "")
Send("{ENTER}")

_DebugOut("Unmount network location")
DriveMapDel($NetDrive)

_DebugOut("Re-enable screensaver")
$key="HKEY_CURRENT_USER\Control Panel\Desktop"
$value="ScreenSaveActive"
If Not Number(RegRead($key, $value)) Then
   RegWrite($key, $value, "REG_SZ", 1)
EndIf

_DebugOut("All done...")

; Reboot the machine
;#include <Process.au3>
;$rc = _RunDos("shutdown -r -t 05")
