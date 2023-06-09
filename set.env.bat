@echo off
rem Country Name
set _C=CN
rem State Or Province Name
set _ST=LiaoNing
rem Locality Name
set _L=DaLian
rem Organization Name
set _O=SSLGroup
rem root ca days
set _ROOT_CA_DAYS=7300
rem ca days
set _CA_DAYS=730
rem jks ca password
set _JKS_PASS=Password
rem specific　openssl path. If not set, use default openssl which setting in PATH
set _OPENSSL="OpenSSL\win64\bin\openssl.exe"