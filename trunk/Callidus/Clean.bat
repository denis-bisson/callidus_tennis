del /Q *.identcache
del /Q *.local
del /Q *.stat
del /Q *.dsk
del /Q *.~dsk
del /Q *.dcu
rd /Q /S __history
rd /Q /S __recovery

cd Components
call clean.bat
cd ..

cd CallidusController
call clean.bat
cd ..

cd CallidusRadar
call clean.bat
cd ..

cd CallidusDisplay
call clean.bat
cd ..

cd Common
call clean.bat
cd ..
