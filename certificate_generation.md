Steps to generate self Signed CA and Intermediate CA to be used by k8s for signing certificates.
----- On CA linux machine:
1- 
```
mkdir certs
```

2-
```
cd certs
```

3-
```
openssl genrsa -out rootca.key 2048
```

4-
```
# openssl req -sha256 -new -x509 -days 1826 -key rootca.key -out rootca.crt
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [XX]:NL
State or Province Name (full name) []:North Holland
Locality Name (eg, city) [Default City]:Amsterdam
Organization Name (eg, company) [Default Company Ltd]:Palo Alto Networks
Organizational Unit Name (eg, section) []:CE
Common Name (eg, your name or your server's hostname) []:ca.emea-ce.local
Email Address []:melamin@paloaltonetworks.com
```

5-
``` 
openssl genrsa -out intermediate1.key 2048
```

6-
```
# openssl req -sha256 -new -key intermediate1.key -out intermediate1.csr
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [XX]:NL
State or Province Name (full name) []:North Holland
Locality Name (eg, city) [Default City]:Amsterdam
Organization Name (eg, company) [Default Company Ltd]:Palo Alto Networks
Organizational Unit Name (eg, section) []:CE
Common Name (eg, your name or your server's hostname) []:Intermediate CA
Email Address []:melamin@paloaltonetworks.com

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:
```

7- 
```
touch certindex
echo 1000 > certserial
echo 1000 > crlnumber
```

8- 
```
# cat ca.conf
[ ca ]
default_ca = myca

[ crl_ext ]
issuerAltName=issuer:copy
authorityKeyIdentifier=keyid:always

[ myca ]
dir = ./
new_certs_dir = $dir
unique_subject = no
certificate = $dir/rootca.crt
database = $dir/certindex
private_key = $dir/rootca.key
serial = $dir/certserial
default_days = 730
default_md = sha256
policy = myca_policy
x509_extensions = myca_extensions

[ myca_policy ]
commonName = supplied
stateOrProvinceName = supplied
countryName = optional
emailAddress = optional
organizationName = supplied
organizationalUnitName = optional

[ myca_extensions ]
basicConstraints = CA:TRUE
subjectAltName  = @alt_names

[ v3_ca ]
basicConstraints = critical,CA:TRUE,pathlen:0
keyUsage = critical,any
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
keyUsage = digitalSignature,keyEncipherment,cRLSign,keyCertSign
extendedKeyUsage = serverAuth
subjectAltName  = @alt_names

[alt_names]
DNS.0 = k8s-master.emea-ce.local
IP.0 = 10.193.86.8
```

9- 
```
openssl ca -batch -config ca.conf -notext -in intermediate1.csr -out intermediate1.crt
```

----- On Master node:

10- Copy the certs and keys to master node:
```
intermediate1.crt
intermediate1.key
rootca.key
rootca.crt
```

11- Add the Certificate to the master trusted store
```
sudo cp rootca.crt /etc/ssl/certs/
sudo cp intermediate1.crt /etc/ssl/certs/
sudo cp rootca.crt /etc/pki/ca-trust/source/anchors/
sudo update-ca-trust extract
```

12- copy the intermediate cert to the /etc/kubernetes/pki/
```
sudo cp intermediate1.crt /etc/kubernetes/pki/ca.crt
sudo cp intermediate1.key /etc/kubernetes/pki/ca.key
```

Ref:
- https://raymii.org/s/tutorials/OpenSSL_command_line_Root_and_Intermediate_CA_including_OCSP_CRL%20and_revocation.html#toc_1
- https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-init/
- https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-certs/
