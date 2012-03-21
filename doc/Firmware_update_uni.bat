@echo off
echo OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO
echo     Softwareupdate Batch v1.0     
echo     auf IPAdresse       
echo     IP:%1    
echo OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO

ftp -n -s:ftpbatch_uni.bat %1

REM echo To exit type Ctrl-C 
REM :ende 
REM goto ende


