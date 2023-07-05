@echo off
cd /d %~dp0

echo Removing dir out
if exist out (
	rd /s/q out
)

echo Creating output structure
mkdir out\newcerts
echo=>out\index.txt
type nul>out\index.txt

echo unique_subject=no>out\index.txt.attr
echo 1000>out\serial
echo Done
