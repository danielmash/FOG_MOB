Software Autoinstall
V. 3.2.0.1

GlobalTIS
---------
Copy CDROM to X:\Path_to_GlobalTIS_CD_contents

Change some information like company address and telephones in autosetup.ini
run makesnapins.bat to build FOG snapinn
Add snapin to FOG with email as snapin argument and reboot task

-GlobalTIS will be installed after reboot and Second stage is to send registration information to the authority:

-Third stage. Checking email from the authority to extract the serial code.
This one is complicated. At the moment we have to do it manually as scripting was not very efficient.

-Fourth: Registration
run gtisregtodo.exe

-Fifth: Tech2win Installation
It sensetive to java version. Currently confirmed work with java6u39.
 
(!) All other parameters hardcoded in *.au3 files
