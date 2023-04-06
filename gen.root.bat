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

call set.env.bat
echo C: %_C%
echo ST: %_ST%
echo L: %_L%
echo O: %_O%
echo ROOT_CA_DAYS: %_ROOT_CA_DAYS%

rem # Generate root cert along with root key
openssl req -config %root_path%ca.cnf -newkey rsa:2048 -nodes -keyout %root_path%out/root.key.pem -new -x509 -days %_ROOT_CA_DAYS% -out %root_path%out/root.crt -subj "/C=%_C%/ST=%_ST%/L=%_L%/O=%_O%/CN=Yokogawa ROOT CA"

rem # Generate cert key
openssl genrsa -out "%root_path%out/cert.key.pem" 2048
