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


rem # Generate root cert along with root key
openssl req -config %root_path%ca.cnf -newkey rsa:2048 -nodes -keyout %root_path%out/root.key.pem -new -x509 -days 7300 -out %root_path%out/root.crt -subj "/C=CN/ST=LiaoNing/L=DaLian/O=Yokogawa/CN=Yokogawa ROOT CA"

rem # Generate cert key
openssl genrsa -out "%root_path%out/cert.key.pem" 2048
