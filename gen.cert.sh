#!/usr/bin/env bash

if [ -z "$1" ]
then
    echo
    echo 'Issue a wildcard SSL certificate with ROOT CA'
    echo
    echo 'Usage: ./gen.cert.sh <domain> [<domain2>] [<domain3>] [<domain4>] [<IP1>] [<IP2>]...'
    echo '    <domain>          The domain name of your site, like "example.dev",'
    echo '                      you will get a certificate for *.example.dev'
    echo '                      Multiple domains are acceptable'
    exit;
fi

SAN=""
for var in "$@"
do
    if [[ ${var} =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        SAN+="IP:${var},"
    else
        SAN+="DNS:*.${var},DNS:${var},"
    fi
done
SAN=${SAN:0:${#SAN}-1}

# Move to root directory
cd "$(dirname "${BASH_SOURCE[0]}")"

. set.env.sh
echo C: ${_C}
echo ST: ${_ST}
echo L: ${_L}
echo O: ${_O}
echo CA_DAYS: ${_CA_DAYS}
echo JKS_PASS: ${_JKS_PASS}

# Generate root certificate if not exists
if [ ! -f "out/root.crt" ]; then
    bash gen.root.sh
fi

# Create domain directory
BASE_DIR="out/$1"
TIME=`date +%Y%m%d-%H%M`
DIR="${BASE_DIR}/${TIME}"
mkdir -p ${DIR}

# Create CSR
openssl req -new -out "${DIR}/$1.csr.pem" \
    -key out/cert.key.pem \
    -reqexts SAN \
    -config <(cat ca.cnf \
        <(printf "[SAN]\nsubjectAltName=${SAN}")) \
	-days ${_CA_DAYS} \
    -subj "/C=${_C}/ST=${_ST}/L=${_L}/O=${_O}/OU=$1/CN=*.$1"

# Issue certificate
# openssl ca -batch -config ./ca.cnf -notext -in "${DIR}/$1.csr.pem" -out "${DIR}/$1.cert.pem"
openssl ca -config ./ca.cnf -days ${_CA_DAYS} -batch -notext \
    -in "${DIR}/$1.csr.pem" \
    -out "${DIR}/$1.crt" \
    -cert ./out/root.crt \
    -keyfile ./out/root.key.pem
	
ln -snf "../cert.key.pem" "${DIR}/$1.key.pem"
ln -snf "../root.crt" "${DIR}/root.crt"

# pkcs12
openssl pkcs12 -export -password pass:${_JKS_PASS} -in "${DIR}/$1.crt" -inkey "out/cert.key.pem" -out "${DIR}/$1.p12" -name "$1"
echo ${_JKS_PASS} > "${DIR}/$1.p12.password.txt"

# Chain certificate with CA
cat "${DIR}/$1.crt" ./out/root.crt > "${DIR}/$1.bundle.crt"
ln -snf "./${TIME}/$1.bundle.crt" "${BASE_DIR}/$1.bundle.crt"
ln -snf "./${TIME}/$1.crt" "${BASE_DIR}/$1.crt"
ln -snf "./${TIME}/$1.p12" "${BASE_DIR}/$1.p12"
ln -snf "./${TIME}/$1.p12.password.txt" "${BASE_DIR}/$1.p12.password.p12"
ln -snf "../cert.key.pem" "${BASE_DIR}/$1.key.pem"
ln -snf "../root.crt" "${BASE_DIR}/root.crt"

# Output certificates
echo
echo "Certificates are located in:"

LS=$([[ `ls --help | grep '\-\-color'` ]] && echo "ls --color" || echo "ls -G")

${LS} -la `pwd`/${BASE_DIR}/*.*
