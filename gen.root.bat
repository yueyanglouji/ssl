@echo off
cd /d %~dp0

if exist out\root.crt (
	echo Root certificate already exists.
	exit 1
)

if not exist out (
	call flush.bat
)

set root_path=%~dp0
set root_path=%root_path:\=/%

call "%~dp0\set.env.bat"
echo C: %_C%
echo ST: %_ST%
echo L: %_L%
echo O: %_O%
echo ROOT_CA_DAYS: %_ROOT_CA_DAYS%
echo OPEN_SSL: %_OPENSSL%
echo     (OPEN_SSL if not set or file not exists, use default openssl which setting in PATH)

if %_OPENSSL%x == x (
	set _OPENSSL=openssl
)

if not exist %_OPENSSL% (
    set _OPENSSL=openssl
)

rem # Generate root cert along with root key
%_OPENSSL% req -config %root_path%ca.cnf -newkey rsa:2048 -nodes -keyout %root_path%out/root.key.pem -new -x509 -days %_ROOT_CA_DAYS% -out %root_path%out/root.crt -subj "/C=%_C%/ST=%_ST%/L=%_L%/O=%_O%/CN=Yokogawa ROOT CA"

rem # Generate cert key
%_OPENSSL% genrsa -out "%root_path%out/cert.key.pem" 2048
