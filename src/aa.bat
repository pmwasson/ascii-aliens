cd ..\build
ca65 -I ..\src -t apple2 ..\src\aa.asm -l aa.dis
cl65 -I ..\src -t apple2 -u __EXEHDR__ ..\src\aa.asm apple2.lib  -o aa.apple2 -C ..\src\start0C00.cfg

copy ..\disk\template_prodos.dsk aa_prodos.dsk
java -jar C:\jar\AppleCommander.jar -p  aa_prodos.dsk aa.system sys < C:\cc65\target\apple2\util\loader.system
java -jar C:\jar\AppleCommander.jar -as aa_prodos.dsk aa bin < aa.apple2 
copy aa_prodos.dsk ..\disk

C:\AppleWin\Applewin.exe -no-printscreen-dlg -d1 aa_prodos.dsk

