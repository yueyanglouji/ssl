@echo off

if "%1"=="" (
    echo
    echo Issue a wildcard SSL certificate with ROOT CA
    echo
    echo Usage: ./gen.cert.sh <domain> [<domain2>] [<domain3>] [<domain4>] [<IP1>] [<IP2>]...
    echo     <domain>          The domain name of your site, like "example.dev",
    echo                       you will get a certificate for *.example.dev
    echo                       Multiple domains are acceptable
    exit
)

set SAN=

set reg="[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*"


setlocal enabledelayedexpansion
for %%i in (%*) do ( 
	set flag="0"
	echo %%i| findstr %reg%>nul && (
		set flag="1"
	) 
	
	
	if !flag!=="1" (
		set SAN=!SAN!IP:%%i,
	) else (
		set SAN=!SAN!DNS:*.%%i,DNS:%%i,
	)

)

set count=0

:loop
if not "!SAN:~%count%,1!"=="" (
	set /a count+=1
	goto loop
)

set /a count=count-1
set SAN=!SAN:~0,%count%!

rem Move to root directory
cd /d %~dp0

rem Generate root certificate if not exists
if not exist out\root.crt (
	call gen.root.bat
)

rem # Create domain directory
set dd=%DATE:~8,2%
set mm=%DATE:~5,2%
set yy=%DATE:~0,4%
set Tmm=%TIME:~3,2%
set Thh=%TIME:~0,2%
set Thh=%Thh: =0%
set TIME=%yy%%mm%%dd%-%Thh%%Tmm%

set root_path_w=%~dp0
set BASE_DIR_W=%root_path_w%out\%1
set DIR_W=%BASE_DIR_W%\%TIME%
mkdir %DIR_W%


set root_path=%root_path_w:\=/%
set BASE_DIR=%BASE_DIR_W:\=/%
set DIR=%DIR_W:\=/%

for /f "delims=" %%a in ('type %root_path_w%ca.cnf') do (
set "str=%%a"
set "str=!str:./out=%root_path%out!"
echo !str! >>%root_path%ca_copy.cnf
)
echo [SAN] >>%root_path_w%ca_copy.cnf
echo subjectAltName=%SAN% >>%root_path_w%ca_copy.cnf

echo subjectAltName=%SAN%
rem Create CSR
openssl req -new -out "%DIR%/%1.csr.pem" -key %root_path%out/cert.key.pem -reqexts SAN -config %root_path%ca_copy.cnf -subj "/C=CN/ST=LiaoNing/L=DaLian/O=Yokogawa/OU=%1/CN=*.%1"

rem Issue certificate
openssl ca -config %root_path%ca_copy.cnf -batch -notext -in "%DIR%/%1.csr.pem" -out "%DIR%/%1.crt" -cert %root_path%out/root.crt -keyfile %root_path%out/root.key.pem	

copy %root_path_w%out\cert.key.pem %DIR:/=\%\%1.key.pem
copy %root_path_w%out\root.crt %DIR:/=\%\root.crt
echo copy %root_path_w%out\cert.key.pem %DIR:/=\%\%1.key.pem
pause

rem pkcs12
openssl pkcs12 -export -password pass:Password -in %DIR%/%1.crt -inkey %DIR%/%1.key.pem -out %DIR%/%1.p12 -name "%1"

del %root_path_w%ca_copy.cnf

rem Chain certificate with CA
copy %DIR_W%\%1.crt + %root_path_w%out\root.crt %DIR_W%\%1.bundle.crt
copy %DIR_W%\%1.bundle.crt %BASE_DIR_W%\%1.bundle.crt
copy %DIR_W%\%1.crt %BASE_DIR_W%\%1.crt
copy %DIR%/%1.key.pem %BASE_DIR_W%\%1.key.pem
copy %DIR%\root.crt %BASE_DIR_W%\root.crt

rem # Output certificates
echo Certificates are located in:

echo %BASE_DIR_W%\%1.crt
echo %BASE_DIR_W%\%1.key.pem
echo %BASE_DIR_W%\%1.p12
