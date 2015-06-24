Software Autoinstall
V. 3.2.0.1


G-IDSS
------
First make sure you copied G-IDSS CD contents to the network share.
Change network share path, username, password in autosetup.au3 and re-run makesnapins.bat
Alternatively put distro on local disk eg C:\Install\GIDSS (which makes SOE 4G bigger) 

-Snapin build instruction for G-IDSS
To record G-IDSS installation run GIDSS\setup.exe /r 
Perform normal install and /r key mean this will record into file C:\WINDOWS\setup.iss
Move C:\WINDOWS\setup.iss to the current snapin build folder as gidss.iss
run make_autogidss_snapin.bat and compiller will embed gidss.iss into autogidss.exe
Upload autogidss.exe to FOG and specify serial number as a parameter
Autoit will catch GIDSS activation window automatically when it apear and insert serial specified in the command line. 

-To test unattended:
GIDSS.exe 1234567890ABCDEF
