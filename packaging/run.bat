@echo off
cd /d "%~dp0"
dosbox\dosbox.exe -noprimaryconf -nolocalconf -conf dosbox.conf -noconsole -exit
