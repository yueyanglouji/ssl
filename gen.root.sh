#!/usr/bin/env bash
cd "$(dirname "${BASH_SOURCE[0]}")"

if [ -f "out/root.crt" ]; then
    echo Root certificate already exists.
    exit 1
fi

if [ ! -d "out" ]; then
    bash flush.sh
fi

bash set.env.sh
echo C: ${_C}
echo ST: ${_ST}
echo L: ${_L}
echo O: ${_O}
echo ROOT_CA_DAYS: ${_ROOT_CA_DAYS}

# Generate root cert along with root key
openssl req -config ca.cnf \
    -newkey rsa:2048 -nodes -keyout out/root.key.pem \
    -new -x509 -days ${_ROOT_CA_DAYS} -out out/root.crt \
    -subj "/C=${_C}/ST=${_ST}/L=${_L}/O=${_O}/CN=Yokogawa ROOT CA"

# Generate cert key
openssl genrsa -out "out/cert.key.pem" 2048
