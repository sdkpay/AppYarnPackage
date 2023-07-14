openssl x509 -inform der -in r_sub_ca.der -pubkey -noout > server_cert_public_key.pem
cat server_cert_public_key.pem | openssl rsa -pubin -outform der | openssl dgst -sha256 -binary | openssl enc -base64
