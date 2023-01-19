#!/bin/bash
# The script has been set not to execute directly.
# Use it as a manual. Keys are deliberately short for educational purposes)
# create / use x509 directory and crtificate structure as follows:
#
#  Netkit_CDP
#   |
#   +--create-x509.sh (this script)
#   |
#   +--ca
#   |   |
#   |   +--root
#   |   |   |
#   |   |   +--openssl.cnf (config for a root ca)
#   |   |   |
#   |   |   \--(various dirs, certs and keys)
#   |   |
#   |   \--intermediate
#   |       |
#   |       +--openssl.cnf (config for an intermediate ca)
#   |       |
#   |       \--(various dirs, certs and keys)
#   |    
#   \--server
#       |
#       +--openssl.cnf (config for a server)
#       |
#       \--(various certs and keys)
# 

# prep the top level dirs
# mkdir x509
# cd x509
Netkit_CDPDIR=$PWD

######### ROOT CA ##########
# prep the ca dirs
cd ${Netkit_CDPDIR}
#mkdir -p ./RootCA/ca/root
cd ./RootCA/ca/root/

mkdir certs crl newcerts private unsigned signed
chmod 700 private
touch index.txt
echo 1000 > serial

# create the root ca key (should really be 4096 bits) "ca_secret"
openssl genrsa -aes256 -out private/ca.key.pem 4096
chmod 400 private/ca.key.pem

# create the root cert
openssl req -config ./openssl.cnf \
      -key private/ca.key.pem \
      -new -x509 \
      -days 7300 \
      -sha256 \
      -extensions v3_ca \
      -out certs/ca.cert.pem

# verify the root cert
openssl x509 -noout -text -in certs/ca.cert.pem

######### INTERMEDIATE CA ###########
# prep the intermediate ca dirs
cd ${Netkit_CDPDIR}
#mkdir -p ./IntermediateCA/ca/intermediate
cd ./IntermediateCA/ca/intermediate/

mkdir certs crl newcerts private csr signed unsigned
chmod 700 private
touch index.txt
echo 1000 > serial

echo 1000 > ./crlnumber

# create the intermediate CA key "intermediate_secret"
openssl genrsa -aes256 -out private/intermediate.key.pem 4096
chmod 400 private/intermediate.key.pem

# create the intermediate cert
openssl req -config ./openssl.cnf \
      -new -sha256 \
      -key private/intermediate.key.pem \
      -out csr/intermediate.csr.pem

########## ROOT CA SIGNS INTERMEDIATE CA ##############
# send the intermediate cert csr to the root ca
cd ${Netkit_CDPDIR}
cp ./IntermediateCA/ca/intermediate/csr/intermediate.csr.pem ./RootCA/ca/root/unsigned/

# get the intermdiate cert signed by the root cert
cd ./RootCA/ca/root/
openssl ca -config ./openssl.cnf \
      -extensions v3_intermediate_ca \
      -days 3650 -notext -md sha256 \
      -in unsigned/intermediate.csr.pem \
      -out signed/intermediate.cert.pem
      
# verify the intermediate cert
openssl x509 -noout -text -in signed/intermediate.cert.pem
      
# verify against root cert      
openssl verify -CAfile certs/ca.cert.pem \
      signed/intermediate.cert.pem      
      
# return it to the intermediate ca
cd ${Netkit_CDPDIR}
cp ./RootCA/ca/root/signed/intermediate.cert.pem ./IntermediateCA/ca/intermediate/certs/
# add root ca to the intermediate ca
cat ./RootCA/ca/root/certs/ca.cert.pem >> ./IntermediateCA/ca/intermediate/certs/intermediate.cert.pem
chmod 444 ./IntermediateCA/ca/intermediate/certs/intermediate.cert.pem

########## SERVER ####################
# prep the server dirs
cd ${Netkit_CDPDIR}
#mkdir server
cd Webserver

# generate the server key (no aes256 this time to permit server unattended restart)
openssl genrsa  -out server.key.pem 2048
chmod 400 server.key.pem

# generate the server cert
openssl req -config ./openssl.cnf \
      -key server.key.pem \
      -new -sha256 \
      -out server.csr.pem


######### INTERMDEDIATE CA SIGNS SERVER CSR #################
# send the server cert csr to the intermediate ca
cd ${Netkit_CDPDIR}
cp ./Webserver/server.csr.pem ./IntermediateCA/ca/intermediate/unsigned/

# get the intermdiate cert signed by the root cert
cd ./IntermediateCA/ca/intermediate/
openssl ca -config ./openssl.cnf \
      -extensions server_cert \
      -days 375 \
      -notext -md sha256 \
      -in unsigned/server.csr.pem \
      -out signed/server.cert.pem

# verify the cert
openssl x509 -noout -text -in signed/server.cert.pem
 

# verify against intermediate cert 
openssl verify -CAfile certs/intermediate.cert.pem signed/server.cert.pem
 
# return it to the server
cd ${Netkit_CDPDIR}
cp ./IntermediateCA/ca/intermediate/signed/server.cert.pem ./Webserver/  
chmod 444 ./Webserver/server.cert.pem






