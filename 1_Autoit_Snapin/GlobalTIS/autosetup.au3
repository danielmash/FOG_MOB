#include <WinAPIShPath.au3>
#include <FileConstants.au3>
#include <Misc.au3>
#include <IE.au3>
#include <Debug.au3>

Opt('MouseCoordMode', 2) ; Mouse click coordinates inside windows client

Local $Email = "" ; Look down for command line checks  
Local $inifile = "autosetup.ini"

Local $SF_1 = IniRead($inifile, "General", "Title", "Auto GlobalTIS Snapin")
Local $sLogPath = IniRead($inifile, "Logging", "Log", "autogtis.log")
Local $SetupLocal = IniRead($inifile, "General", "Setup", "C:\Install\GlobalTIS\setup.exe")
Local $NetShare = IniRead($inifile, "Net", "Share", "")
Local $NetPath = IniRead($inifile, "Net", "Path", "")
Local $NetDrive = IniRead($inifile, "Net", "Drive", "X:")
Local $NetDomUser = IniRead($inifile, "Net", "User", "guest")
Local $NetPasswd = IniRead($inifile, "Net", "Pass", "") 
Local $Companyname = IniRead($inifile, "Registration", "Companyname", "")
Local $Street = IniRead($inifile, "Registration", "Street", "")
Local $Postcode = IniRead($inifile, "Registration", "Postcode", "")
Local $Suburb = IniRead($inifile, "Registration", "Suburb", "")
Local $Country = IniRead($inifile, "Registration", "Country", "Australia")
Local $Language = IniRead($inifile, "Registration", "Language", "English (Australia)")
Local $Phone = IniRead($inifile, "Registration", "Phone", "")
Local $Fax = IniRead($inifile, "Registration", "Fax", "")
Local $PersonName = IniRead($inifile, "Registration", "PersonName", "")
Local $PersonLanguage = IniRead($inifile, "Registration", "PersonLanguage", "English (Australia)")
Local $Dealer = IniRead($inifile, "License", "Dealer", "")

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

;_DebugOut("Wait system boots timeout")
;sleep(7000)

; Set App Name
AutoItWinSetTitle($SF_1)

Func _WinWaitActivate($title,$text,$timeout=0)
	WinWait($title,$text,$timeout)
	If Not WinActive($title,$text) Then WinActivate($title,$text)
	WinWaitActive($title,$text,$timeout)
EndFunc

_DebugOut("Checking if GlobalTIS is already installed.")
Local $aDetails = FileGetShortcut(@DesktopCommonDir & "\GlobalTIS.lnk" )
If Not @error Then
  _DebugOut("Found previous Installation. Please uninstall first.")
  RunWait($aDetails[1] & "\Uninstall GlobalTIS\Uninstall GlobalTIS.exe")
  Sleep(3000)
EndIf

$SETUP = $NetDrive & $NetPath
_DebugOut("Trying to map " & $NetShare & " to " & $NetDrive)

If DriveMapAdd($NetDrive, $NetShare, 0, $NetDomUser, $NetPasswd) Then
   _DebugOut("Success.! Using " & $SETUP)
ElseIf Not DriveMApGet($NetDrive) Then
   Sleep(3000)
   DriveMapAdd($NetDrive, $NetShare, 0, $NetDomUser, $NetPasswd) 
   If @error Then 
      _DebugReport("Unable to mount network share.", 1, 0)
      $SETUP = $SetupLocal ; Give another try locally
      _DebugOut("Trying locally from " & $SETUP)
   EndIf
EndIf

If Not FileExists( $SETUP ) Then
   _DebugReport("No installation media found in " & $SETUP,1,1) ; Exit
EndIf

_DebugOut("Disable screensaver")
$key="HKEY_CURRENT_USER\Control Panel\Desktop"
$value="ScreenSaveActive"
If Number(RegRead($key, $value)) Then
   RegWrite($key, $value, "REG_SZ", 0)
EndIf

_DebugOut("Running Auto GlobalTIS installation: " & $SETUP )
_DebugOut("Doing clicks. Please be patient.")
Run($SETUP)
If @error Then _DebugReport("Problem to run installer executable",1,1) ; Script will be terminated

_WinWaitActivate("[CLASS:SunAwtFrame]","")
If @error Then _DebugReport("Issue with focus on SunAwtFrame.",1,1) ; Script will be terminated

Sleep(3000)
MouseClick("left",297,240) ; Click OK

_WinWaitActivate("[CLASS:SunAwtDialog]","")  
Send("{TAB}{ENTER}")

_WinWaitActivate("[CLASS:SunAwtFrame]","")
If @error Then _DebugReport("Issue with focus on SunAwtFrame.",1,1) ; Script will be terminated
Send("!n")

_WinWaitActivate("[CLASS:SunAwtFrame]","")
If @error Then _DebugReport("Issue with focus on SunAwtFrame (License window).",1,1) ; Script will be terminated
Send("!a!n")

_DebugOut("Please wait 3-7 minutes until installation finished.")
While WinActivate("[CLASS:SunAwtFrame]","")  
  ;MouseClick("left",580,287)
  Send("!n!i!d")
  Sleep(666)
WEnd

_DebugOut("...done")

_DebugOut("Unmount network location")
DriveMapDel($NetDrive)

_DebugOut("Checking command line agument given.")
If Not $CmdLine[0] Then 
   $Email = ""
Else
   $Email = $CmdLine[1]
EndIf

If EmailValidation($Email) Then 
 
  $Email=inputbox("Registration", "Please enter email to perform registration or cancel to do it later.") 
 
  If @error Or EmailValidation($Email) Then 
 
      _DebugOut("Re-enable screensaver")
      $key="HKEY_CURRENT_USER\Control Panel\Desktop"
      $value="ScreenSaveActive"
      If Not Number(RegRead($key, $value)) Then
          RegWrite($key, $value, "REG_SZ", 1)
      EndIf
  
     _DebugOut("Registration not possible at this time. Exit script.")

      Exit
   EndIf
Else
   _DebugOut("Pause 7 seconds to let Tomcat and Transbase services to settle down.")
   sleep(7000)
EndIf

Func EmailValidation($Email) 

     $localpart = "[[:alnum:]!#$%&'*+-/=?^_`{|}~.]+"
     $domainname = "[[:alnum:].-]+\.[[:alnum:]]+"

     If StringRegExp($Email, '(?i)^(' & $localpart & ')@(' & $domainname & ')$', 0) Then 
       Return 0
     Else
       Return 1
     EndIf

EndFunc

; Retrieve details about the shortcut.
    Local $aDetails = FileGetShortcut(@DesktopCommonDir & "\GlobalTIS.lnk" )
    If Not @error Then
       Local $URL = IniRead($aDetails[0] , "InternetShortcut", "URL", "http://localhost:9080/tis2web")
    Else
       Local $URL = IniRead(@ProgramFilesDir & "\GlobalTIS\GlobalTIS.url" , "InternetShortcut", "URL", "http://localhost:9080/tis2web")
    EndIf

_DebugOut("Starting IE registration window " & $URL)
Local $oIE = _IECreate($URL)
If @error Then 
   MsgBox(0, $SF_1, "Problem with accessing GlobalTIS server on " & $URL & ". Please make sure it's installed. Might be reboot and try again.")
   _IEQuit($oIE)
   Exit
EndIf

WinSetState("", "", @SW_MAXIMIZE)

$oIEhwnd = _IEPropertyGet($oIE, "hwnd")
ControlShow($oIEhwnd, "", "Internet Explorer_Server1")

;workaround yser connected when testing forms
If StringInStr(_IEBodyReadText($oIE),"This user id and password is already in use",0,1) Then 
   ControlSend($oIEhwnd, "", "Internet Explorer_Server1", "{TAB}{TAB}{TAB}{TAB}{TAB}{ENTER}")
EndIf

_IELoadWait($oIE)   

If Not StringInStr(_IEBodyReadText($oIE),"Please fill in your dealership information",0,1) Then
   MsgBox(0, $SF_1,"Looks like something went wrong here ...")
   Exit
EndIf

;List all elements on page
;Local $oElements = _IETagNameAllGetCollection($oIE)
;For $oElement In $oElements
;    If $oElement.id Then _DebugOut("Tagname: " & $oElement.tagname & "id: " & $oElement.id & "innerText: " & $oElement.innerText)
;Next

$oLinks = _IETagNameGetCollection($oIE, "button")
If @error Then _DebugReportEx("Problem editing dealership data", False, True) ; Script will be terminated

For $oLink In $oLinks
    If StringInStr(_IEPropertyGet($oLink, "innertext"), "Edit dealership data") Then
        _DebugOut("Edit dealership data")
        _IEAction($oLink, "click")
        _IELoadWait($oIE) 
        Local $oForm = _IEFormGetCollection($oIE, 0)
        _IEFormElementSetValue(_IEFormElementGetCollection($oForm, 0), $Dealer)
        _IEFormElementSetValue(_IEFormElementGetCollection($oForm, 1), $Companyname)
        _IEFormElementSetValue(_IEFormElementGetCollection($oForm, 2), $Street)
        _IEFormElementSetValue(_IEFormElementGetCollection($oForm, 3), $Postcode)
        _IEFormElementSetValue(_IEFormElementGetCollection($oForm, 4), $Suburb)
        _IEFormElementOptionSelect(_IEFormElementGetCollection($oForm, 6), $Country, 1, "byText")
        _IEFormElementOptionSelect(_IEFormElementGetCollection($oForm, 7), $Language, 1, "byText")
        _IEFormElementSetValue(_IEFormElementGetCollection($oForm, 8), $Phone)
        _IEFormElementSetValue(_IEFormElementGetCollection($oForm, 9), $Fax)
        _IEFormElementSetValue(_IEFormElementGetCollection($oForm, 10),$Email)
        _IEFormElementSetValue(_IEFormElementGetCollection($oForm, 11),$PersonName)
        _IEFormElementOptionSelect(_IEFormElementGetCollection($oForm, 12), $PersonLanguage, 1, "byText")

        $fLinks1 = _IETagNameGetCollection($oIE, "button")
        If @error Then _DebugReportEx("Problem with dealership data form elements", False, True) ; Script will be terminated
        For $fLink1 In $fLinks1
           If StringInStr(_IEPropertyGet($fLink1, "innertext"), "Save") Then 
              _IEAction($fLink1, "click")
              ExitLoop
           EndIf
        Next
        _IELoadWait($oIE)
        If StringInStr(_IEBodyReadText($oIE),"Dealership data stored",0,1) Then 
            ControlSend($oIEhwnd, "", "Internet Explorer_Server1","{TAB}{TAB}{TAB}{TAB}{ENTER}")
	EndIf
     ExitLoop
     EndIf      
Next

_IELoadWait($oIE)

$oLinks = _IETagNameGetCollection($oIE, "button")
If @error Then _DebugReportEx("Problem with online registration button", False, True) ; Script will be terminated

For $oLink In $oLinks

    If StringInStr(_IEPropertyGet($oLink, "innertext"), "Online Registration") Then
        _DebugOut("Online Registration")
        _IEAction($oLink, "click")
        _IELoadWait($oIE)

        ;If StringInStr(_IEBodyReadText($oIE),"UnknownHostException",0,1) Then 
        ;    ControlSend($oIEhwnd, "", "Internet Explorer_Server1","{TAB}{TAB}{TAB}{TAB}{ENTER}")
	;Else
        ;    _DebugReportEx("Problem with online registration. Perhaps connectivity?", False, True) ; Script will be terminated
	;EndIf

        _DebugOut("All done...")

        ExitLoop
     EndIF

Next

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
