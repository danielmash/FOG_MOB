@echo on


if [%*] == [] goto fail

rem Decompress bundle components
..\7zip\7za.exe x %1\Windows\Disk1\InstData\Resource1.zip $IA_PROJECT_DIR$
mkdir $IA_PROJECT_DIR$\ProjectFiles\CustomCode 
..\7zip\7za.exe e %1\Windows\Disk1\InstData\Resource1.zip uninstallerCustomCode.jar 
move uninstallerCustomCode.jar $IA_PROJECT_DIR$\ProjectFiles\CustomCode\CustomCode.jar 
..\7zip\7za.exe e %1\Windows\Disk1\InstData\VM\install.exe InstallerData\Execute.zip
..\7zip\7za.exe x Execute.zip $IA_PROJECT_DIR$
..\7zip\7za.exe e -o$IA_PROJECT_DIR$ Execute.zip InstallScript.iap_xml
..\7zip\7za.exe x -o$IA_PROJECT_DIR$\ProjectFiles\tomcat\tomcat $IA_PROJECT_DIR$\ProjectFiles\tomcat\tomcat_zg_ia_sf.jar 
..\7zip\7za.exe x -o$IA_PROJECT_DIR$\ProjectFiles\Transbase\tb $IA_PROJECT_DIR$\ProjectFiles\Transbase\tb_zg_ia_sf.jar
del /q /f Execute.zip

..\7zip\7za.exe x %1\Windows\Disk1\InstData\VM\install.exe Windows\resource\jre
rem make sure no spaces at the end of earch vm.parameter unless vmpack will not recognised by Install Anywhere
echo vm.name=globaltis> vm.properties
echo vm.platform=windows>> vm.properties
echo vm.exe.path=bin\\java.exe>> vm.properties
echo vm.platform.flavor=win32>> vm.properties
..\7zip\7za.exe a -r -tzip -mx0 vm.zip .\Windows\resource\jre\*.*
..\7zip\7za.exe a -tzip globaltis.vm vm.properties vm.zip
del /q /f /s vm.properties vm.zip 
rmdir /s /q Windows
move $IA_PROJECT_DIR$ _IA_PROJECT

echo ^[OK^] ---
echo ^[-^] Move globaltis.vm to eg ."%ProgramFiles(x86)%\InstallAnywhere 2014 SP1\resource\installer_vms\" 
echo ^[-^] Open _IA_PROJECT\InstallScript.iap_xml project file.
echo ^[-^] Adjust "silent" in UI and "bindeled" vm as "globaltis". 
echo ^[-^] Build project

goto end

:fail
echo Please specify path to GlobalTIS install CD contents

:en
pause
