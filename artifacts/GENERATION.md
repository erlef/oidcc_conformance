# Generation of keys

```bash
# Generate Private Keys
openssl ecparam -genkey -name prime256v1 -noout -out artifacts/client.priv.pem
openssl ecparam -genkey -name prime256v1 -noout -out artifacts/server.priv.pem

# Generate Public Keys
openssl ec -in ./artifacts/client.priv.pem -pubout -out ./artifacts/client.pub.pem
openssl ec -in ./artifacts/server.priv.pem -pubout -out ./artifacts/server.pub.pem

# Generate JWKs for public & private keys
npx eckles ./artifacts/client.priv.pem > ./artifacts/client.priv.jwk
npx eckles ./artifacts/client.pub.pem > ./artifacts/client.pub.jwk
npx eckles ./artifacts/server.priv.pem > ./artifacts/server.priv.jwk
npx eckles ./artifacts/server.pub.pem > ./artifacts/server.pub.jwk

# Generate JWK sets
cat ./artifacts/client.priv.jwk| jq '{"keys": [. * {"use": "sig", "kid": "client", "alg": "ES256"}]}' > ./artifacts/client.priv.jwkset
cat ./artifacts/client.pub.jwk| jq '{"keys": [. * {"use": "sig", "kid": "client", "alg": "ES256"}]}' > ./artifacts/client.pub.jwkset
cat ./artifacts/server.priv.jwk| jq '{"keys": [. * {"use": "sig", "kid": "server", "alg": "ES256"}]}' > ./artifacts/server.priv.jwkset
cat ./artifacts/server.pub.jwk| jq '{"keys": [. * {"use": "sig", "kid": "server", "alg": "ES256"}]}' > ./artifacts/server.pub.jwkset
```