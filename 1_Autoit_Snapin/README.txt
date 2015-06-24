Software Autoinstall
V. 3.2.0.1

Automation script code based on Autoit v.3 (https://www.autoitscript.com)
Utilities in use to build snapin:
Aut2Exe --to compile script into snapin exe (similar for 64 bit)
Extras\Au3Record --to record some basic movements through the instalation (Optional. Thiw way is not efficient. Better to do it manually)
Au3Info  --to gather the information about widgets (Increases efficiency with GUI controls see ControlClick)

Snapin build using modified 7zip self extraction module http://7zsfx.info/en/

Stages:
1) FOG executing snapin.exe with command line argiments. 
2) It add RunOnce registry entry with /ai key and serial.
3) Move snapin.exe to %SystemRoot% to let windows to found it
4) FOG reboot the machine
5) On next boot snapin.exe will be executed from %SystemRoot%
6) And deleted itself when finish.
7) Vuala!

Please read README in each project subdirectory.
