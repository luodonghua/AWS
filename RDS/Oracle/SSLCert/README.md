
``` bash
# create directories for wallet and cert files
mkdir wallet cert
```

``` bash
curl -o cert/global-bundle.pem https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem

[oracle@ol ~]$ grep "BEGIN CERTIFICATE" cert/global-bundle.pem |wc -l
118
```

```bash
# Split the files into format cert-000.pem format and store in cert directory
 csplit -s -z -f cert/cert- -b %03d.pem cert/global-bundle.pem '/-----BEGIN CERTIFICATE-----/' '{*}'
```

```bash
[oracle@ol ~]$ ls -l cert/cert-*|head -n 5
-rw-r--r-- 1 oracle oinstall 1472 Oct  5 19:59 cert/cert-000.pem
-rw-r--r-- 1 oracle oinstall 1472 Oct  5 19:59 cert/cert-001.pem
-rw-r--r-- 1 oracle oinstall 1472 Oct  5 19:59 cert/cert-002.pem
-rw-r--r-- 1 oracle oinstall 1456 Oct  5 19:59 cert/cert-003.pem
-rw-r--r-- 1 oracle oinstall 1468 Oct  5 19:59 cert/cert-004.pem
```

```bash
# Create auto-logon wallet and import all these certs

orapki wallet create -wallet ./wallet -auto_login_only   

for i in `ls ./cert/cert-*`
do
	orapki wallet add -wallet ./wallet -trusted_cert -cert $i -auto_login_only
done
```

```bash
# sample output
[oracle@ol ~]$ for i in `ls ./cert/cert-*`
> do
>   orapki wallet add -wallet ./wallet -trusted_cert -cert $i -auto_login_only
> done
Oracle PKI Tool Release 21.0.0.0.0 - Production
Version 21.0.0.0.0
Copyright (c) 2004, 2022, Oracle and/or its affiliates. All rights reserved.

Operation is successfully completed.
Oracle PKI Tool Release 21.0.0.0.0 - Production
Version 21.0.0.0.0
Copyright (c) 2004, 2022, Oracle and/or its affiliates. All rights reserved.

...

Oracle PKI Tool Release 21.0.0.0.0 - Production
Version 21.0.0.0.0
Copyright (c) 2004, 2022, Oracle and/or its affiliates. All rights reserved.

Operation is successfully completed.
```

```bash
orapki wallet display -wallet ./wallet

[oracle@ol ~]$ orapki wallet display -wallet ./wallet |grep Subject|wc -l
118

[oracle@ol ~]$ orapki wallet display -wallet ./wallet
Oracle PKI Tool Release 21.0.0.0.0 - Production
Version 21.0.0.0.0
Copyright (c) 2004, 2022, Oracle and/or its affiliates. All rights reserved.

Requested Certificates:
User Certificates:
Trusted Certificates:
Subject:        L=Seattle,CN=Amazon RDS us-east-2 Root CA ECC384 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS ap-east-1 Root CA RSA4096 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        CN=Amazon RDS me-south-1 Root CA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,ST=Washington,L=Seattle,C=US
Subject:        L=Seattle,CN=Amazon RDS sa-east-1 Root CA ECC384 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        CN=Amazon RDS af-south-1 Root CA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,ST=Washington,L=Seattle,C=US
Subject:        L=Seattle,CN=Amazon RDS ap-southeast-3 Root CA ECC384 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS sa-east-1 Root CA RSA4096 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS ca-central-1 Root CA RSA4096 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        CN=Amazon RDS us-west-1 2019 CA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,L=Seattle,ST=Washington,C=US
Subject:        CN=Amazon RDS eu-south-1 CA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,L=Seattle,ST=Washington,C=US
Subject:        L=Seattle,CN=Amazon RDS us-east-2 Root CA RSA2048 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS us-east-1 Root CA RSA4096 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS ca-central-1 Root CA ECC384 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS ap-northeast-1 Root CA RSA2048 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS il-central-1 Root CA ECC384 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS us-west-2 Root CA ECC384 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS Beta us-east-1 Root CA RSA4096 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS ap-south-2 Root CA RSA2048 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS ap-south-1 Root CA RSA4096 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS eu-south-1 Root CA ECC384 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS af-south-1 Root CA RSA4096 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS Preview us-east-2 Root CA RSA2048 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        CN=Amazon RDS Beta us-east-1 2019 CA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,L=Seattle,ST=Washington,C=US
Subject:        L=Seattle,CN=Amazon RDS me-central-1 Root CA RSA2048 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        CN=Amazon RDS ap-northeast-2 2019 CA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,L=Seattle,ST=Washington,C=US
Subject:        CN=Amazon RDS eu-north-1 2019 CA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,L=Seattle,ST=Washington,C=US
Subject:        L=Seattle,CN=Amazon RDS us-west-2 Root CA RSA2048 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS eu-north-1 Root CA RSA2048 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS us-west-1 Root CA RSA4096 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS ap-southeast-2 Root CA RSA2048 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS ap-southeast-1 Root CA RSA4096 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        CN=Amazon RDS eu-west-2 2019 CA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,L=Seattle,ST=Washington,C=US
Subject:        L=Seattle,CN=Amazon RDS af-south-1 Root CA ECC384 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS ap-southeast-4 Root CA RSA2048 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS ap-southeast-3 Root CA RSA4096 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS eu-west-1 Root CA RSA2048 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        CN=Amazon RDS ap-southeast-1 2019 CA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,L=Seattle,ST=Washington,C=US
Subject:        L=Seattle,CN=Amazon RDS ap-east-1 Root CA RSA2048 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS ap-northeast-1 Root CA ECC384 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS eu-west-2 Root CA ECC384 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS ap-northeast-3 Root CA RSA4096 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS ap-northeast-2 Root CA ECC384 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS eu-central-1 Root CA ECC384 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS eu-west-3 Root CA ECC384 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS ap-south-2 Root CA ECC384 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        CN=Amazon RDS me-south-1 CA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,L=Seattle,ST=Washington,C=US
Subject:        L=Seattle,CN=Amazon RDS sa-east-1 Root CA RSA2048 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS ca-central-1 Root CA RSA2048 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS eu-central-2 Root CA RSA4096 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS me-south-1 Root CA ECC384 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS us-east-1 Root CA RSA2048 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS il-central-1 Root CA RSA4096 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS eu-south-2 Root CA RSA2048 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS eu-south-1 Root CA RSA4096 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS me-south-1 Root CA RSA4096 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS Beta us-east-1 Root CA RSA2048 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS ap-south-1 Root CA RSA2048 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS eu-west-3 Root CA RSA4096 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS af-south-1 Root CA RSA2048 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        CN=Amazon RDS sa-east-1 2019 CA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,L=Seattle,ST=Washington,C=US
Subject:        CN=Amazon RDS us-east-2 2019 CA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,L=Seattle,ST=Washington,C=US
Subject:        CN=Amazon RDS eu-south-1 Root CA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,ST=Washington,L=Seattle,C=US
Subject:        CN=Amazon RDS Beta Root 2019 CA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,ST=Washington,L=Seattle,C=US
Subject:        L=Seattle,CN=Amazon RDS us-west-1 Root CA RSA2048 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS ap-southeast-1 Root CA RSA2048 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        CN=Amazon RDS ap-northeast-1 2019 CA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,L=Seattle,ST=Washington,C=US
Subject:        CN=Amazon RDS af-south-1 CA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,L=Seattle,ST=Washington,C=US
Subject:        L=Seattle,CN=Amazon RDS us-west-2 Root CA RSA4096 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS ap-southeast-3 Root CA RSA2048 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS ap-southeast-2 Root CA RSA4096 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        CN=Amazon RDS eu-west-1 2019 CA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,L=Seattle,ST=Washington,C=US
Subject:        L=Seattle,CN=Amazon RDS ap-southeast-4 Root CA ECC384 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS us-east-1 Root CA ECC384 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS ap-northeast-3 Root CA RSA2048 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS ap-northeast-2 Root CA RSA4096 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS ap-east-1 Root CA ECC384 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        CN=Amazon RDS Preview Root 2019 CA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,ST=Washington,L=Seattle,C=US
Subject:        L=Seattle,CN=Amazon RDS ap-southeast-1 Root CA ECC384 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS ap-southeast-2 Root CA ECC384 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS eu-central-2 Root CA RSA2048 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS eu-south-2 Root CA ECC384 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS eu-central-1 Root CA RSA4096 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        CN=Amazon RDS eu-central-1 2019 CA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,L=Seattle,ST=Washington,C=US
Subject:        L=Seattle,CN=Amazon RDS il-central-1 Root CA RSA2048 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS eu-south-1 Root CA RSA2048 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS me-south-1 Root CA RSA2048 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS Beta us-east-1 Root CA ECC384 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        CN=Amazon RDS ca-central-1 2019 CA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,L=Seattle,ST=Washington,C=US
Subject:        CN=Amazon RDS Root 2019 CA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,ST=Washington,L=Seattle,C=US
Subject:        L=Seattle,CN=Amazon RDS eu-south-2 Root CA RSA4096 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS us-west-1 Root CA ECC384 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS eu-west-3 Root CA RSA2048 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS eu-west-2 Root CA RSA4096 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS ap-northeast-3 Root CA ECC384 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS eu-central-2 Root CA ECC384 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        CN=Amazon RDS us-east-1 2019 CA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,L=Seattle,ST=Washington,C=US
Subject:        L=Seattle,CN=Amazon RDS Preview us-east-2 Root CA ECC384 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        CN=Amazon RDS us-west-2 2019 CA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,L=Seattle,ST=Washington,C=US
Subject:        L=Seattle,CN=Amazon RDS us-east-2 Root CA RSA4096 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        CN=Amazon RDS ap-south-1 2019 CA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,L=Seattle,ST=Washington,C=US
Subject:        L=Seattle,CN=Amazon RDS ap-northeast-2 Root CA RSA2048 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS ap-northeast-1 Root CA RSA4096 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS eu-west-1 Root CA ECC384 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS ap-south-1 Root CA ECC384 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS me-central-1 Root CA ECC384 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        CN=Amazon RDS ap-northeast-3 2019 CA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,L=Seattle,ST=Washington,C=US
Subject:        L=Seattle,CN=Amazon RDS eu-central-1 Root CA RSA2048 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS ap-south-2 Root CA RSA4096 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS Preview us-east-2 Root CA RSA4096 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        CN=Amazon RDS eu-west-3 2019 CA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,L=Seattle,ST=Washington,C=US
Subject:        L=Seattle,CN=Amazon RDS me-central-1 Root CA RSA4096 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS eu-north-1 Root CA RSA4096 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        CN=Amazon RDS ap-southeast-2 2019 CA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,L=Seattle,ST=Washington,C=US
Subject:        CN=Amazon RDS Preview us-east-2 2019 CA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,L=Seattle,ST=Washington,C=US
Subject:        L=Seattle,CN=Amazon RDS ap-southeast-4 Root CA RSA4096 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS eu-west-2 Root CA RSA2048 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS eu-west-1 Root CA RSA4096 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
Subject:        L=Seattle,CN=Amazon RDS eu-north-1 Root CA ECC384 G1,ST=WA,OU=Amazon RDS,O=Amazon Web Services\, Inc.,C=US
```

```bash
# chksum for the file
[oracle@ol ~]$ sha1sum cert/global-bundle.pem  wallet/cwallet.sso
739992e99e645ecddd894bedd7e934b1c5dae895  cert/global-bundle.pem
d0886b098c8f37f9ec16a387b2e792c84901f4a3  wallet/cwallet.sso
```



