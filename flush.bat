@echo off
cd /d %~dp0

echo Removing dir out
if exist out (
	rd /s/q out
)
 

echo Creating output structure
mkdir out
cd out
mkdir newcerts
echo=>index.txt
type nul>index.txt

echo unique_subject=no>index.txt.attr
echo 1000>serial
echo Done
